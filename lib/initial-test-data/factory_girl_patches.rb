require 'active_support'

module FactoryGirl
  class Sequence
    def initialize_with_patch(name, *args, &proc)
      options = args.extract_options!
      enumerator = args.first || InitialTestData::SequenceEnumerator.new(name)
      initialize_without_patch(name, enumerator, options, &proc)
    end
    alias_method_chain :initialize, :patch
  end
end
