module UserPrefs
  module MacroMethods
    # I think this is a good name for the macro, but Rubocop disagrees...
    def has_preferences(column_name = 'preferences') # rubocop:disable Naming/PredicateName
      class_attribute :prefs_column

      self.prefs_column = column_name.to_s
      include UserPrefs
    end
  end
end
