require 'active_support'
begin LoadError
  require 'factory_girl'
rescue
end

module FactoryGirl
  module SequenceWithCachedEnumerator
    def initialize(name, *args, &proc)
      options = args.extract_options!
      enumerator = args.first || InitialTestData::SequenceEnumerator.new(name)
      super(name, enumerator, options, &proc)
    end
  end

  if FactoryGirl.const_defined?(:Sequence)
    Sequence.send(:prepend, SequenceWithCachedEnumerator)
  end
end
