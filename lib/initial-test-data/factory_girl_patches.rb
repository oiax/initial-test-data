require 'active_support'

module FactoryGirl
  module SequenceWithCachedEnumerator
    def initialize(name, *args, &proc)
      options = args.extract_options!
      enumerator = args.first || InitialTestData::SequenceEnumerator.new(name)
      super(name, enumerator, options, &proc)
    end
  end

  Sequence.send(:prepend, SequenceWithCachedEnumerator)
end
