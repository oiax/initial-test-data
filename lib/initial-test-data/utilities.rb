require 'active_support'

module InitialTestData
  module Utilities
    def store(record, name, options = {})
      model_name = options[:as] || record.class.model_name.singular
      record_name = name.to_s

      RECORD_IDS[model_name] ||= HashWithIndifferentAccess.new

      if RECORD_IDS[model_name].has_key?(record_name)
        raise "The key '#{record_name}' already exists " +
          "for #{record.class.model_name.name}."
      elsif !record.kind_of?(ActiveRecord::Base)
        raise "Given object is not an instance of ActiveRecord::Base."
      elsif record.new_record?
        raise "Given record is not persisted yet."
      else
        RECORD_IDS[model_name][record_name] = record.id
      end
    end

    def fetch(model_name, name)
      if RECORD_IDS[model_name].kind_of?(Hash) &&
         RECORD_IDS[model_name][name]
         klass = model_name.to_s.camelize.constantize
         klass.find RECORD_IDS[model_name][name]
      else
        raise "No record is registered with the key '#{model_name}' and '#{name}'."
      end
    end
  end
end
