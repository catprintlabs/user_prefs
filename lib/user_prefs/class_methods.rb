# frozen_string_literal: true

module UserPrefs
  module ClassMethods
    def preference(name = nil, opts = {})
      validate_name(name)

      defined_prefs << name
      default_prefs[name.to_s] ||= opts[:default]

      define_method("#{name}_pref") do
        prefs_attr.key?(name) ? prefs_attr[name] : opts[:default]
      end

      define_method("#{name}_pref=") do |new_value|
        self.prefs_attr = prefs_attr.merge(Hash[name, new_value])
      end

      define_method("#{name}_pref?") do
        prefs_attr.key?(name)
      end
    end

    private

    def validate_name(name)
      raise PreferenceError, 'Preference name must be specified.' unless name
      raise PreferenceError, "#{name} has already been specified." if defined_prefs.include?(name)
    end
  end
end
