module InitialTestData
  class SequenceEnumerator
    def initialize(name)
      @name = name
      @value = self.class.initial_value_for(name)

      self.class.register(name, self)
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
        enumerators[name.to_s] = enumerator
      end

      def initial_value_for(name)
        cached_values[name.to_s] || 1
      end

      def reset
        enumerators.each_value do |enum|
          enum.reset
        end
      end

      def save
        File.open(data_path, 'w') do |f|
          f.write enumerators.map { |k, v| [ k, v.peek ] }.to_h.to_yaml
        end
      end

      private
      def cached_values
        return @cached_values if @cached_values
        @cached_values = {}
        if File.exists?(data_path)
          begin
            @cached_values.merge! YAML.load_file(data_path)
          rescue SyntaxError
          end
        end
        @cached_values
      end

      def data_path
        Rails.root.join('tmp', 'initial_data_enumerators.yml')
      end
    end
  end
end
