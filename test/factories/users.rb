FactoryGirl.define do
  factory :user do
    sequence(:name) { |n| "test#{n}" }
    birthday Date.today
  end
end
