require 'rubygems'
require 'minitest/autorun'
require 'active_support'
require 'active_record'
require 'rails'
require 'fileutils'

$:.unshift File.dirname(__FILE__) + '/../lib'

FileUtils.rm_f(File.dirname(__FILE__) + '/../tmp/test.sqlite3')

app = Class.new(Rails::Application)
app.config.active_support.test_order = :random
app.config.eager_load = false
app.initialize!

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'tmp/test.sqlite3',
  pool: 5,
  timeout: 5000
)

require 'migrations/create_users'
require 'migrations/create_products'

require 'models/user'
require 'models/product'
