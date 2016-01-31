initial-test-data
=================

The `initial-test-data` is a tool to create a text fixture for Rails applications.

Overview
--------

Although the Rails itself has a standard mechanism
([Fixtures](http://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html)),
it is rather cumbersome to construct a real (often complicated) data structure
from YAML files.

The `initial-test-data` provides a a way to create a test fixture using Active Record, Factory Girl, etc.

Installation
------------

Add the following line to `Gemfile`:

```ruby
gem 'initial-test-data', group: :test
```

Run `bin/bundle install` on the terminal.

Configuration of test framework
-------------------------------

### MiniTest

To be written.

### RSpec

Edit `spec/rails_helper.rb` like this:

```ruby
ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'initial-test-data'

RSpec.configure do |config|
  config.before(:suite) do
    InitialTestData.load('spec')
  end
end
```

Usage
-----

### Synopsis

* Create `initial_data` subdirectory in the `test` or `spec` directory.
* Put any ruby scripts on this file.
* Run your test suite.

### Caching data

The `initial-test-data` generates the md5 digest of all ruby scripts in
the `initial_data` directory and stores it to the `_initial_data_digest`
table of the test database.

If the generated md5 digest is equal to the previously stored value,
data initializing process will be skipped.

### Load Order

The files in the `initial_data` directory are loaded in alphabetical order.
If you control the load order, you should make a YAML file called `_index.yml`,
which has a content like this:

```yaml
- products
- customers
- orders
```

### Database Cleaner

The `initial-test-data` utilizes the `database_cleaner` gem to truncate
all tables except `_initial_data_digest` and `schema_migrations`.

If you want to keep some tables intact, specify the `except` option:

```ruby
RSpec.configure do |config|
  config.before(:suite) do
    InitialTestData.load('spec', except: %w(country_names))
  end
end
```

This option is passed to the `DatabaseCleaner.strategy=` method.

Example
-------

### MiniTest and Active Record

To be written

### RSpec, Capybara and Factory Girl

```ruby
# spec/initial_data/customers.rb

include FactoryGirl::Syntax::Methods

0.upto(9) do |n|
  create(:customer, email: "test#{n}@example.com")
end

# spec/features/manage_customers_spec.rb

require 'rails_helper'

feature 'Manage customers' do
  let(:customer) { Customer.find_by(email: 'test0@example.com') }

  scenario 'Change the name of a customer' do
    visit root_path

    find('table.customers td', text: customer.email)
      .find(:xpath, '..').click_link('Edit')

    fill_in 'Given Name', with: 'John'
    fill_in 'Family Name', with: 'Doe'
    click_button 'Update'

    customer.reload
    expect(customer.given_name).to eq('John')
    expect(customer.family_name).to eq('Doe')
  end
end
```
