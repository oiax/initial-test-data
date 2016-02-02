require 'digest/md5'
require 'database_cleaner'
require 'active_support'

module InitialTestData
  DIGEST_TABLE_NAME = '_initial_data_digest'
  RECORD_IDS = HashWithIndifferentAccess.new

  class << self
    def load(*args)
      @options = args.extract_options!
      @dir = args[0] || 'test'

      klass = define_class

      md5_digest = generate_md5_digest
      md5_digest_cache = klass.first.try(:md5_value)

      needs_reinitialization = true
      record_ids_path = Rails.root.join('tmp', 'initial_data_record_ids.yml')
      if File.exists?(record_ids_path) && md5_digest == md5_digest_cache
        begin
          RECORD_IDS.merge! YAML.load_file(record_ids_path)
          needs_reinitialization = false
        rescue SyntaxError
        end
      end

      if needs_reinitialization
        initialize_data

        digest = klass.first
        digest ||= klass.new
        digest.md5_value = md5_digest
        digest.save

        File.open(record_ids_path, 'w') do |f|
          f.write RECORD_IDS.to_yaml
        end
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

      Dir[Rails.root.join(@dir, 'initial_data', '*.{rb,yml}')].each do |f|
        md5.update File.new(f).read
      end

      dirs = [ 'app/models' ]
      if @options[:monitoring].kind_of?(Array)
        dirs += @options[:monitoring]
      end

      dirs.each do |d|
        Dir[Rails.root.join(d, '**', '*.rb')].each do |f|
          md5.update File.new(f).read
        end
      end

      md5.hexdigest
    end

    def initialize_data
      strategy_options = @options.slice(:only, :except)
      unless strategy_options.has_key?(:only)
        strategy_options[:except] ||= []
        unless strategy_options[:except].include?(DIGEST_TABLE_NAME)
          strategy_options[:except] << DIGEST_TABLE_NAME
        end
      end

      DatabaseCleaner.strategy = :truncation, strategy_options
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


    def save_record_ids

    end

    def load_record_ids
    end
  end
end
