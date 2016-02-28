require 'initial-test-data/initial_test_data'
require 'initial-test-data/utilities'
require 'initial-test-data/sequence_enumerator'

if Object.const_defined?(:FactoryGirl)
  require 'initial-test-data/factory_girl_patches'
end
