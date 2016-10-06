module UserPrefs
  module MacroMethods
    def has_preferences(column_name = 'preferences')
      class_attribute :prefs_column

      self.prefs_column = column_name
      include UserPrefs
    end
  end
end
