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

Edit `test/test_helper.rb` like this:

```ruby
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'initial-test-data'

InitialTestData.load

class ActiveSupport::TestCase
  include InitialTestData::Utilities

  # (snip)
end
```

Note that the default value of the first argument of `load` method is `'test'`,
so you can omit it when your test scripts are located in the `test` directory.

### RSpec

Edit `spec/rails_helper.rb` like this:

```ruby
ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'initial-test-data'

RSpec.configure do |config|
  config.include InitialTestData::Utilities

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
the `initial_data` directory and `app/models` directory,
then stores it to the `_initial_data_digest` table of the test database.

When the generated md5 digest is equal to the previously stored value,
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

### Options for the `InitialTestData.load` method

#### `except`

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

#### `monitoring`

By default the `initial-test-data` monitors the `initial_data` directory
under the `test` directory (or the directory specified by the first argument)
and the `app/models` directory.

If you want to add monitoring target directories, specify `monitoring`
option to the `InitialTestData.load` method:

```ruby
RSpec.configure do |config|
  config.before(:suite) do
    InitialTestData.load('spec',
      monitoring: [ 'app/services', 'lib', 'spec/factories' ]
  end
end
```

You should use relative paths from the `Rails.root`.

### Utility methods: `store` and `fetch`

The `initial-test-data` provides two utility methods, `store` and `fetch`,
to make it easy to refer the initialized records in your tests.

You can use the `store` method within the initialization scripts
in order to register an ActiveRecord object by name:

```ruby
include InitialTestData::Utilities

store(Customer.create(...), :john)
store(ShopOwner.create(...), :mike)
```

Then, you can get this record with `fetch` method in the test scripts:

```ruby
customer = fetch(:customer, :john)
show_owner = fetch(:shop_owner, :mike)
```

The fetch method treats `:john` and `"john"` as the same key.

Note that the `initial-test-data` creates a YAML file
named `initial_data_record_ids.yml` in the `tmp` directory
to track the primary key values of registered records.
Please do not remove or tamper it.

Example
-------

### MiniTest and Active Record

```ruby
# test/initial_data/customers.rb

include InitialTestData::Utilities

0.upto(9) do |n|
  c = Customer.create(
    email: "test#{n}@example.com",
    given_name: 'John',
    family_name: 'Doe'
  )
  store(c, "test#{n}")
end

# test/integration/manage_customers_test.rb

require 'test_helper'

class ManageCustomersTest < ActionDispatch::IntegrationTest
  test "Change the name of a customer" do
    customer = fetch(:customer, :test0)

    get "/customers/#{customer.id}/edit"
    assert_response :success

    patch "/customers/#{customer.id}",
      customer: { given_name: 'Mike', family_name: 'Smith' }
    assert_redirected_to [ assigns(:customer) ]

    follow_redirect!
    assert_select "h1", "Listing Customers"

    customer.reload

    assert_equal 'Mike', customer.given_name
    assert_equal 'Smith', customer.family_name
  end
end
```

### RSpec, Capybara and Factory Girl

```ruby
# spec/initial_data/customers.rb

include FactoryGirl::Syntax::Methods
include InitialTestData::Utilities

0.upto(9) do |n|
  c = create(:customer, email: "test#{n}@example.com")
  store(c, "test#{n}")
end

# spec/features/manage_customers_spec.rb

require 'rails_helper'

feature 'Manage customers' do
  let(:customer) { fetch(:customer, :test0) }

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

License
-------

The `initial-test-data` is distributed under the MIT license. ([MIT-LICENSE](https://github.com/oiax/initial-test-data/blob/master/MIT-LICENSE))

Author
------

Tsutomu Kuroda (t-kuroda@oiax.jp)
