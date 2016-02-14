$:.unshift File.dirname(__FILE__)
require 'test_helper'
require 'initial-test-data'
require 'fileutils'

class InitialTestDataTest < ActiveSupport::TestCase
  include InitialTestData::Utilities

  def setup
    FileUtils.rm_f(File.dirname(__FILE__) + '/../tmp/initial_data_record_ids.yml')
  end

  test "should import data into test database" do
    InitialTestData.import(quiet: true)
    assert_equal 3, User.count

    File.open(File.dirname(__FILE__) + '/initial_data/users2.rb', 'w') do |f|
      f.puts "store User.create!(name: 'dave', birthday: '1960-04-01'), :dave"
    end

    InitialTestData.import(quiet: true)
    assert_equal 4, User.count

    File.delete(File.dirname(__FILE__) + '/initial_data/users2.rb')

    InitialTestData.import(quiet: true)
    assert_equal 3, User.count
  end

  test "should import data from test/extra directory using _index.yml" do
    InitialTestData.import('test/extra', quiet: true)

    assert_equal 1, User.count
    assert_equal 1, Product.count
    assert_equal 2, Order.count
  end

  test "should truncate only users table" do
    Product.delete_all
    Product.create!(name: 'A', price: 100)
    User.create!(name: 'Foo', birthday: '2000-01-01')
    InitialTestData.import(only: %w(users), quiet: true)
    assert_equal 3, User.count
    assert_equal 1, Product.count
  end

  test "should keep the products table" do
    Product.delete_all
    Product.create!(name: 'A', price: 100)
    User.create!(name: 'Foo', birthday: '2000-01-01')
    InitialTestData.import(except: %w(products), quiet: true)
    assert_equal 3, User.count
    assert_equal 1, Product.count
  end

  test "should import and fetch test records" do
    InitialTestData.import(quiet: true)

    user1 = fetch(:user, :bob)
    user2 = fetch(:user, :cate)
    assert_equal 'bob', user1.name
    assert_equal 'cate', user2.name
  end
end
