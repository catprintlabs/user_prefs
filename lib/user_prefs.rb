require 'user_prefs/class_methods'
require 'user_prefs/macro_methods'
require "user_prefs/version"

module UserPrefs
  class ColumnError < StandardError; end

  def self.included(base)
    unless base.column_names.include?(base.prefs_column)
      raise(ColumnError, "#{base.name} must have a column named "\
                         "'#{base.prefs_column}' with type 'text'.")
    end

    base.class_eval do
      class_attribute :defined_prefs

      self.defined_prefs ||= []

      serialize prefs_column.to_sym, HashWithIndifferentAccess
    end

    base.extend(ClassMethods)
  end

  def prefs
    prefs_attr.merge(Hash[self.class.defined_prefs.map { |k| [k, send("#{k}_pref")] }])
  end

  def add_pref(key, value)
    prefs_attr[key] = value
  end

  def delete_pref(key)
    self.prefs_attr = prefs_attr.reject { |k, _v| k.to_s == key.to_s }
  end

  def method_missing(method_name, *args, &block)
    if (match_data = method_name.to_s.match(/(\w+)_pref(=|\?)?/))
      preference_method(match_data[1], match_data[2], args.first)
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    method_name =~ /(\w+)_pref(=|\?)?/ || super
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
