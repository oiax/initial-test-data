module InitialTestData
  class SequenceEnumerator
    def initialize(name)
      @name = name
      @index = self.class.register(name, self)
      @value = self.class.initial_value_for(name, @index)
    end

    def peek
      @value
    end

    def next
      @value = @value.next
    end

    def reset
      @value = 1
    end

    class << self
      def enumerators
        @enumerators ||= {}
        @enumerators
      end

      def register(name, enumerator)
        enumerators[name.to_s] ||= []
        enumerators[name.to_s] << enumerator
        enumerators[name.to_s].size - 1
      end

      def initial_value_for(name, index)
        cached_values_for(name)[index] || 1
      end

      def reset
        enumerators.each_value do |enums|
          enums.each do |enum|
            enum.reset
          end
        end
      end

      def save
        hash = {}
        enumerators.each do |name, enums|
          hash[name] = enums.map(&:peek)
        end
        File.open(data_path, 'w') do |f|
          f.write hash.to_yaml
        end
      end

      private
      def cached_values_for(name)
        if @cached_values
          return @cached_values[name.to_s] || []
        end
        @cached_values = {}
        if File.exists?(data_path)
          begin
            @cached_values.merge! YAML.load_file(data_path)
          rescue SyntaxError
          end
        end
        @cached_values[name.to_s] || []
      end

      def data_path
        Rails.root.join('tmp', 'initial_data_enumerators.yml')
      end
    end
  end
end
