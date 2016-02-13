require 'rubygems'
require 'minitest/autorun'
require 'active_support'
require 'active_record'
require 'rails'

$:.unshift File.dirname(__FILE__) + '/../lib'

File.delete(File.dirname(__FILE__) + '/../tmp/test.sqlite3')

app = Class.new(Rails::Application)
app.config.eager_load = false
app.initialize!

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'tmp/test.sqlite3',
  pool: 5,
  timeout: 5000
)

class CreateUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      t.string :name
      t.date :birthday
    end
  end
end

CreateUsers.migrate(:up)
