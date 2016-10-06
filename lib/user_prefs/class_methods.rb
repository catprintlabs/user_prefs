module UserPrefs
  module ClassMethods
    def preference(name, opts = {})
      defined_prefs << name
      define_method("#{name}_pref") do
        prefs_attr[name] || opts[:default]
      end

      define_method("#{name}_pref=") do |new_value|
        prefs_attr[name] = new_value
      end

      define_method("#{name}_pref?") do
        prefs_attr.key?(name)
      end
    end
  end
end
