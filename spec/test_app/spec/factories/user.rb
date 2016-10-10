FactoryGirl.define do
  factory :user do
    name        'Test User'
    email       'testuser@test.com'
    preferences { HashWithIndifferentAccess.new }
  end

  trait :with_one_preference do
    preferences { HashWithIndifferentAccess.new(one: 'foo') }
  end

  trait :with_two_preferences do
    preferences { HashWithIndifferentAccess.new(one: 'foo', two: 'bar') }
  end
end
