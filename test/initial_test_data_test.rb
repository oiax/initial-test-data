$:.unshift File.dirname(__FILE__)
require 'test_helper'
require 'initial-test-data'

class InitialTestDataTest < ActiveSupport::TestCase
  test "should load data into test database" do
    InitialTestData.load
  end
end
