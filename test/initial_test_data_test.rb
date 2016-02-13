$:.unshift File.dirname(__FILE__)
require 'test_helper'
require 'initial-test-data'

class InitialTestDataTest < ActiveSupport::TestCase
  include InitialTestData::Utilities

  test "should load data into test database" do
    InitialTestData.load
    assert User.count, 3

    File.open(File.dirname(__FILE__) + '/initial_data/users2.rb', 'w') do |f|
      f.write "store User.create!(name: 'dave', birthday: '1960-04-01'), :dave"
    end

    InitialTestData.load
    assert User.count, 4

    File.delete(File.dirname(__FILE__) + '/initial_data/users2.rb')

    InitialTestData.load
    assert User.count, 3
  end

  test "should load and fetch test records" do
    InitialTestData.load

    user1 = fetch(:user, :bob)
    user2 = fetch(:user, :cate)
    assert user1.name, 'bob'
    assert user2.name, 'cate'
  end
end
