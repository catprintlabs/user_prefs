require 'spec_helper'

describe UserPrefs do
  before(:each) { @user = FactoryGirl.create(:user) }

  context 'has_preferences' do
    it 'should define the default preferences column name' do
      User.class_eval do
        has_preferences :preferences
      end
      User.prefs_column.should eq('preferences')
    end

    it 'should define a specified preferences column name' do
      User.class_eval do
        has_preferences :preferences2
      end
      User.prefs_column.should eq('preferences2')
    end

    it "should raise a ColumnError when specifying a column with name 'prefs'" do
      begin
        User.class_eval do
          has_preferences :prefs
        end
      rescue StandardError => e
        expect(e.class).to eq(UserPrefs::ColumnError)
        expect(e.message).to eq("Preference column name cannot be named 'prefs'.")
      end
    end

    it 'should raise a ColumnError when specifying a column that does not exist' do
      begin
        User.class_eval do
          has_preferences :preferences3
        end
      rescue StandardError => e
        expect(e.class).to eq(UserPrefs::ColumnError)
        expect(e.message).to eq("User must have column 'preferences3'.")
      end
    end

    it 'should raise a ColumnError when specifying a column that is not of type text' do
      begin
        User.class_eval do
          has_preferences :preferences4
        end
      rescue StandardError => e
        expect(e.class).to eq(UserPrefs::ColumnError)
        expect(e.message).to eq("preferences4 must be of type 'text'.")
      end
    end
  end

  context 'default_prefs' do
    it 'should return an empty hash with no prefs specified' do
      User.class_eval do
        has_preferences
      end
      User.default_prefs.should eq({})
    end

    it 'should return a hash of all defined prefs with their defaults' do
      User.class_eval do
        has_preferences
        preference :foo, default: 'bar'
        preference :foo2, default: 'bar2'
      end
      User.default_prefs.should eq('foo' => 'bar', 'foo2' => 'bar2')
    end

    it 'should return a hash of all defined prefs even with no default specified' do
      User.class_eval do
        has_preferences
        preference :foo, default: 'bar'
        preference :foo2
      end
      User.default_prefs.should eq('foo' => 'bar', 'foo2' => nil)
    end
  end

  context 'preference' do
    it 'should be able to define a preference with no default' do
      User.class_eval do
        has_preferences
        preference :foo
      end
      User.defined_prefs.should =~ [:foo]
    end

    it 'should be able to define multiple preferences with no default' do
      User.class_eval do
        has_preferences
        preference :foo
        preference :bar
      end
      User.defined_prefs.should =~ [:foo, :bar]
    end

    it 'should be able to define multiple preferences, one with default one without' do
      User.class_eval do
        has_preferences
        preference :foo, default: 'bar'
        preference :bar
      end
      User.defined_prefs.should =~ [:foo, :bar]
    end

    it 'should be able to define multiple preferences, all with defaults' do
      User.class_eval do
        has_preferences
        preference :foo, default: 'bar'
        preference :bar, default: 'foo'
      end
      User.defined_prefs.should =~ [:foo, :bar]
    end

    it 'should raise an error if no name is provided' do
      begin
        User.class_eval do
          has_preferences
          preference
        end
      rescue StandardError => e
        expect(e.class).to eq(UserPrefs::PreferenceError)
        expect(e.message).to eq('Preference name must be specified.')
      end
    end

    it 'should raise an error if the same name is provided twice' do
      begin
        User.class_eval do
          has_preferences
          preference :foo
          preference :foo
        end
      rescue StandardError => e
        expect(e.class).to eq(UserPrefs::PreferenceError)
        expect(e.message).to eq('foo has already been specified.')
      end
    end
  end

  context 'dynamic methods' do
    before(:each) do
      User.class_eval do
        has_preferences
        preference :foo
      end
    end

    context 'getter method' do
      it 'should be created for a specified preference' do
        expect(@user.respond_to?('foo_pref')).to be(true)
      end

      it 'should return nil when no default is specified' do
        expect(@user.foo_pref).to be(nil)
      end

      it 'should return the new value when overwritten' do
        @user.preferences[:foo] = 'bar'
        expect(@user.foo_pref).to eq('bar')
      end

      it 'should return the default value when specified' do
        User.class_eval do
          preference :foo2, default: 'bar'
        end
        expect(@user.foo2_pref).to eq('bar')
      end
    end

    context 'setter method' do
      it 'should be created for a specified preference' do
        expect(@user.respond_to?('foo_pref=')).to be(true)
      end

      it 'should set a new value when being called' do
        expect(@user.foo_pref).to be(nil)
        @user.foo_pref = 'bar'
        expect(@user.foo_pref).to eq('bar')
      end

      it 'should overwrite the default value when being called' do
        User.class_eval do
          preference :foo2, default: 'bar'
        end
        expect(@user.foo2_pref).to eq('bar')
        @user.foo2_pref = 'bar2'
        expect(@user.foo2_pref).to eq('bar2')
      end

      it 'should overwrite the default boolean value when being called' do
        User.class_eval do
          preference :foo2, default: true
        end
        expect(@user.foo2_pref).to be_truthy
        @user.foo2_pref = false
        expect(@user.foo2_pref).to be_falsy
      end
    end

    context 'presence method' do
      it 'should be created for a specified preference' do
        expect(@user.respond_to?('foo_pref?')).to be(true)
      end

      it 'should return false when no default is specified' do
        expect(@user.foo_pref?).to be(false)
      end

      it 'should return false when a default is specified' do
        User.class_eval do
          preference :foo2, default: 'bar'
        end
        expect(@user.foo2_pref?).to be(false)
      end

      it 'should return true when a value has been specified' do
        @user.foo_pref = 'bar'
        expect(@user.foo_pref?).to be(true)
      end

      it 'should return true when a default is specified and overwritten' do
        User.class_eval do
          preference :foo2, default: 'bar'
        end
        @user.foo2_pref = 'bar2'
        expect(@user.foo2_pref?).to be(true)
      end
    end
  end

  context 'prefs' do
    it 'should return a non-specified preference with no default' do
      User.class_eval do
        has_preferences
        preference :one
      end
      @user.prefs.should eq('one' => nil)
    end

    it 'should return an overwritten non-specified preference with no default' do
      User.class_eval do
        has_preferences
        preference :one
      end
      user = FactoryGirl.create(:user, :with_one_preference)
      user.one_pref = 'bar'
      user.prefs.should eq('one' => 'bar')
    end

    it 'should return an already specified preference' do
      User.class_eval do
        has_preferences
        preference :one
      end
      user = FactoryGirl.create(:user, :with_one_preference)
      user.prefs.should eq('one' => 'foo')
    end

    it 'should return an overwritten specified preference' do
      User.class_eval do
        has_preferences
        preference :one
      end
      user = FactoryGirl.create(:user, :with_one_preference)
      user.one_pref = 'bar'
      user.prefs.should eq('one' => 'bar')
    end

    it 'should return one default preference' do
      User.class_eval do
        has_preferences
        preference :three, default: 'foobar'
      end
      @user.prefs.should eq('three' => 'foobar')
    end

    it 'should return an overwritten default preference' do
      User.class_eval do
        has_preferences
        preference :three, default: 'foobar'
      end
      @user.three_pref = 'foo_bar'
      @user.prefs.should eq('three' => 'foo_bar')
    end

    it 'should return two already specified preferences, one default, and one non-specified' do
      User.class_eval do
        has_preferences
        preference :one
        preference :two
        preference :three, default: 'foobar'
        preference :four
      end
      user = FactoryGirl.create(:user, :with_two_preferences)
      user.prefs.should eq('one' => 'foo', 'two' => 'bar', 'three' => 'foobar', 'four' => nil)
    end

    it 'should return overwritten specified and default preferences' do
      User.class_eval do
        has_preferences
        preference :one
        preference :two
        preference :three, default: 'foobar'
      end
      user = FactoryGirl.create(:user, :with_two_preferences)
      user.one_pref   = 'four'
      user.two_pref   = 'three'
      user.three_pref = 'two'
      user.four_pref  = 'one'
      user.prefs.should eq('one' => 'four', 'two' => 'three', 'three' => 'two', 'four' => 'one')
    end

    it 'should not persist changes without a save' do
      User.class_eval do
        has_preferences
        preference :one
        preference :two
        preference :three, default: 'foobar'
        preference :four
      end
      user = FactoryGirl.create(:user, :with_two_preferences)
      user.one_pref   = 'four'
      user.two_pref   = 'three'
      user.three_pref = 'two'
      user.four_pref  = 'one'
      user.prefs.should eq('one' => 'four', 'two' => 'three', 'three' => 'two', 'four' => 'one')
      user.reload
      user.prefs.should eq('one' => 'foo', 'two' => 'bar', 'three' => 'foobar', 'four' => nil)
    end

    it 'should persist changes with a save' do
      User.class_eval do
        has_preferences
        preference :one
        preference :two
        preference :three, default: 'foobar'
      end
      user = FactoryGirl.create(:user, :with_two_preferences)
      user.one_pref   = 'four'
      user.two_pref   = 'three'
      user.three_pref = 'two'
      user.four_pref  = 'one'
      user.prefs.should eq('one' => 'four', 'two' => 'three', 'three' => 'two', 'four' => 'one')
      user.save!
      user.reload
      user.prefs.should eq('one' => 'four', 'two' => 'three', 'three' => 'two', 'four' => 'one')
    end
  end

  context 'prefs_column' do
    it 'should NOT return a non-specified preference with no default' do
      User.class_eval do
        has_preferences
        preference :one
      end
      @user.preferences.should eq({})
    end

    it 'should return an overwritten non-specified preference with no default' do
      User.class_eval do
        has_preferences
        preference :one
      end
      user = FactoryGirl.create(:user, :with_one_preference)
      user.one_pref = 'bar'
      user.preferences.should eq('one' => 'bar')
    end

    it 'should return an already specified preference' do
      User.class_eval do
        has_preferences
        preference :one
      end
      user = FactoryGirl.create(:user, :with_one_preference)
      user.preferences.should eq('one' => 'foo')
    end

    it 'should return an overwritten specified preference' do
      User.class_eval do
        has_preferences
        preference :one
      end
      user = FactoryGirl.create(:user, :with_one_preference)
      user.one_pref = 'bar'
      user.preferences.should eq('one' => 'bar')
    end

    it 'should NOT return one default preference' do
      User.class_eval do
        has_preferences
        preference :three, default: 'foobar'
      end
      @user.preferences.should eq({})
    end

    it 'should return an overwritten default preference' do
      User.class_eval do
        has_preferences
        preference :three, default: 'foobar'
      end
      @user.three_pref = 'foo_bar'
      @user.preferences.should eq('three' => 'foo_bar')
    end

    it 'should return two already specified preferences, no default, and no non-specified' do
      User.class_eval do
        has_preferences
        preference :one
        preference :two
        preference :three, default: 'foobar'
        preference :four
      end
      user = FactoryGirl.create(:user, :with_two_preferences)
      user.preferences.should eq('one' => 'foo', 'two' => 'bar')
    end

    it 'should return overwritten specified and default preferences' do
      User.class_eval do
        has_preferences
        preference :one
        preference :two
        preference :three, default: 'foobar'
      end
      user = FactoryGirl.create(:user, :with_two_preferences)
      user.one_pref   = 'four'
      user.two_pref   = 'three'
      user.three_pref = 'two'
      user.four_pref  = 'one'
      user.preferences.should eq('one' => 'four', 'two' => 'three',
                                 'three' => 'two', 'four' => 'one')
    end

    it 'should not persist changes without a save' do
      User.class_eval do
        has_preferences
        preference :one
        preference :two
        preference :three, default: 'foobar'
        preference :four
      end
      user = FactoryGirl.create(:user, :with_two_preferences)
      user.one_pref   = 'four'
      user.two_pref   = 'three'
      user.three_pref = 'two'
      user.four_pref  = 'one'
      user.preferences.should eq('one' => 'four', 'two' => 'three',
                                 'three' => 'two', 'four' => 'one')
      user.reload
      user.preferences.should eq('one' => 'foo', 'two' => 'bar')
    end

    it 'should persist changes with a save' do
      User.class_eval do
        has_preferences
        preference :one
        preference :two
        preference :three, default: 'foobar'
      end
      user = FactoryGirl.create(:user, :with_two_preferences)
      user.one_pref   = 'four'
      user.two_pref   = 'three'
      user.three_pref = 'two'
      user.four_pref  = 'one'
      user.preferences.should eq('one' => 'four', 'two' => 'three',
                                 'three' => 'two', 'four' => 'one')
      user.save!
      user.reload
      user.preferences.should eq('one' => 'four', 'two' => 'three',
                                 'three' => 'two', 'four' => 'one')
    end
  end

  context 'add_pref' do
    before(:each) do
      User.class_eval do
        has_preferences
        preference :foo, default: 'bar'
      end
    end

    it 'should add a pref' do
      @user.prefs.should eq('foo' => 'bar')
      @user.add_pref('foo2', 'bar2')
      @user.prefs.should eq('foo' => 'bar', 'foo2' => 'bar2')
    end

    it 'should not persist without a save' do
      @user.add_pref('foo2', 'bar2')
      @user.prefs.should eq('foo' => 'bar', 'foo2' => 'bar2')
      @user.reload
      @user.prefs.should eq('foo' => 'bar')
    end

    it 'should persist with a save' do
      @user.add_pref('foo2', 'bar2')
      @user.prefs.should eq('foo' => 'bar', 'foo2' => 'bar2')
      @user.save!
      @user.reload
      @user.prefs.should eq('foo' => 'bar', 'foo2' => 'bar2')
    end
  end

  context 'add_pref' do
    before(:each) do
      User.class_eval do
        has_preferences
        preference :foo, default: 'bar'
      end
    end

    it 'should return to the default when deleting a specified pref with a default' do
      @user.foo_pref = 'bar2'
      @user.prefs.should eq('foo' => 'bar2')
      @user.delete_pref('foo')
      @user.prefs.should eq('foo' => 'bar')
    end

    it 'should delete an already specified pref' do
      user = FactoryGirl.create(:user, :with_one_preference)
      user.prefs.should eq('foo' => 'bar', 'one' => 'foo')
      @user.delete_pref('one')
      @user.prefs.should eq('foo' => 'bar')
    end

    it 'should delete an added pref' do
      @user.prefs.should eq('foo' => 'bar')
      @user.add_pref('foo2', 'bar2')
      @user.prefs.should eq('foo' => 'bar', 'foo2' => 'bar2')
      @user.delete_pref('foo2')
      @user.prefs.should eq('foo' => 'bar')
    end

    it 'should not persist without a save' do
      user = FactoryGirl.create(:user, :with_one_preference)
      user.prefs.should eq('foo' => 'bar', 'one' => 'foo')
      user.delete_pref('one')
      user.reload
      user.prefs.should eq('foo' => 'bar', 'one' => 'foo')
    end

    it 'should persist with a save' do
      user = FactoryGirl.create(:user, :with_one_preference)
      user.prefs.should eq('foo' => 'bar', 'one' => 'foo')
      user.delete_pref('one')
      user.save!
      user.reload
      user.prefs.should eq('foo' => 'bar')
    end
  end
end
