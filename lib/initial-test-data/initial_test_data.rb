require 'digest/md5'
require 'database_cleaner'

class InitialTestData
  DIGEST_TABLE_NAME = '_initial_data_digest'

  class << self
    def load(dir = 'test')
      @dir = dir.to_s

      klass = define_class

      digest_path = Rails.root.join('tmp', 'initial_data.md5')

      md5_digest = generate_md5_digest
      md5_digest_cache = klass.first.try(:md5_value)

      unless md5_digest == md5_digest_cache
        initialize_data
        digest ||= klass.new
        digest.md5_value = md5_digest
        digest.save
      end
    end

    private
    def define_class
      conn = ActiveRecord::Base.connection

      unless conn.table_exists?(DIGEST_TABLE_NAME)
        conn.create_table(DIGEST_TABLE_NAME) do |t|
          t.string :md5_value
        end
      end

      Class.new(ActiveRecord::Base) do
        self.table_name = DIGEST_TABLE_NAME
      end
    end

    def generate_md5_digest
      md5 = Digest::MD5.new
      Dir[Rails.root.join(@dir, 'initial_data', '*.rb')].each do |f|
        md5.update File.new(f).read
      end

      md5.hexdigest
    end

    def initialize_data
      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.clean

      yaml_path = Rails.root.join(@dir, 'initial_data', '_index.yml')
      if File.exist?(yaml_path)
        table_names = YAML.load_file(yaml_path)
        table_names.each do |table_name|
          path = Rails.root.join(@dir, 'initial_data', "#{table_name}.rb")
          if File.exist?(path)
            puts "Creating #{table_name}...."
            require path
          end
        end
      else
        Dir[Rails.root.join(@dir, 'initial_data', '*.rb')].each do |f|
          table_name = f.match(/(\w+)\.rb$/)[1]
          puts "Creating #{table_name}...."
          require f
        end
      end
    end
  end
end