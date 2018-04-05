require 'user_prefs/class_methods'
require 'user_prefs/macro_methods'
require 'user_prefs/version'

module UserPrefs
  class ColumnError < StandardError; end
  class PreferenceError < StandardError; end

  class << self
    def included(base)
      validate_column_and_type(base) unless RUBY_ENGINE == :opal || pending_migrations?

      base.class_eval do
        class_attribute :defined_prefs, :default_prefs

        self.defined_prefs ||= []
        self.default_prefs ||= {}

        serialize(prefs_column.to_sym, UserPrefs.hash_type)
      end

      base.extend(ClassMethods)
    end

    def hash_type
      if const_defined?('HashWithIndifferentAccess')
        Object.const_get('HashWithIndifferentAccess')
      else
        Object.const_get('Hash')
      end
    end

    private

    # Probably a nicer way to do this, but this will bypass column validation
    # in the case that the user hasn't migrated the preferences column yet.
    def pending_migrations?
      begin
        ActiveRecord::Migration.check_pending!
      rescue ActiveRecord::PendingMigrationError
        true
      end
    end

    def no_column?(base)
      !base.columns_hash[base.prefs_column]
    end

    def name_conflict?(base)
      base.prefs_column == 'prefs'
    end

    def wrong_type?(base)
      base.columns_hash[base.prefs_column] &&
        base.columns_hash[base.prefs_column].type.to_s != 'text'
    end

    def validate_column_and_type(base)
      raise ColumnError, "Preference column name cannot be named 'prefs'." if name_conflict?(base)
      raise ColumnError, "#{base.name} must have column '#{base.prefs_column}'." if no_column?(base)
      raise ColumnError, "#{base.prefs_column} must be of type 'text'." if wrong_type?(base)
    end
  end

  def prefs
    prefs_attr.merge(Hash[self.class.defined_prefs.map { |k| [k, send("#{k}_pref")] }])
  end

  def add_pref(key, value)
    self.prefs_attr = prefs_attr.merge(Hash[key, value])
  end

  def delete_pref(key)
    self.prefs_attr = prefs_attr.reject { |k, _v| k.to_s == key.to_s }
  end

  def method_missing(method_name, *args, &block)
    if (match_data = method_name.to_s.match(/(\w+)_pref(=|\?)?\z/))
      preference_method(match_data[1], match_data[2], args.first)
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    method_name =~ /(\w+)_pref(=|\?)?\z/ || super
  end

  private

  def prefs_attr
    send(self.class.prefs_column)
  end

  def prefs_attr=(value)
    send("#{self.class.prefs_column}=", value)
  end

  def preference_method(key, method = nil, new_value = nil)
    case method
    when '?' then prefs_attr.key?(key)
    when '=' then prefs_attr[key] = new_value
    else prefs_attr[key]
    end
  end
end

ActiveRecord::Base.class_eval do
  extend UserPrefs::MacroMethods
end

unless RUBY_ENGINE == 'opal'
  # Now if we are NOT running inside of opal, set things up so opal can find
  # the files. The whole thing is rescued in case the opal gem is not available.
  # This would happen if the gem is being used server side ONLY.
  begin
    require 'opal'
    Opal.append_path File.expand_path('..', __FILE__).untaint
  rescue LoadError # rubocop:disable Lint/HandleExceptions
  end
end
