require 'digest/md5'
require 'database_cleaner'
require 'active_support/hash_with_indifferent_access'
require 'active_record'
require 'rails'

module InitialTestData
  DIGEST_TABLE_NAME = '_initial_data_digest'
  RECORD_IDS = HashWithIndifferentAccess.new

  class << self
    def import(*args)
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
        RECORD_IDS.clear
        initialize_data

        digest = klass.first
        digest ||= klass.new
        digest.md5_value = md5_digest
        digest.save

        File.open(record_ids_path, 'w') do |f|
          f.write RECORD_IDS.to_hash.to_yaml
        end
      end
    end

    private
    def define_class
      conn = ActiveRecord::Base.connection

      unless ditest_table_exists?
        conn.create_table(DIGEST_TABLE_NAME) do |t|
          t.string :md5_value
        end
      end

      Class.new(ActiveRecord::Base) do
        self.table_name = DIGEST_TABLE_NAME
      end
    end

    def ditest_table_exists?
      conn = ActiveRecord::Base.connection
      ::Rails::VERSION::MAJOR >= 5 ?
        conn.data_source_exists?(DIGEST_TABLE_NAME) :
        conn.table_exists?(DIGEST_TABLE_NAME)
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
      tables = non_empty_tables

      if @options[:only].kind_of?(Array)
        tables = tables & @options[:only]
      elsif @options[:except].kind_of?(Array)
        tables = tables - @options[:except]
      end

      DatabaseCleaner.strategy = :truncation, { only: tables }
      DatabaseCleaner.clean

      yaml_path = Rails.root.join(@dir, 'initial_data', '_index.yml')
      if File.exist?(yaml_path)
        table_names = YAML.load_file(yaml_path)
        table_names.each do |table_name|
          path = Rails.root.join(@dir, 'initial_data', "#{table_name}.rb")
          if File.exist?(path)
            puts "Creating #{table_name}...." unless @options[:quiet]
            load path
          end
        end
      else
        Dir[Rails.root.join(@dir, 'initial_data', '*.rb')].each do |path|
          table_name = path.match(/(\w+)\.rb$/)[1]
          puts "Creating #{table_name}...." unless @options[:quiet]
          load path
        end
      end
    end

    def non_empty_tables
      tables = []

      conn = ActiveRecord::Base.connection
      data_sources = ::Rails::VERSION::MAJOR >= 5 ?
        conn.data_sources : conn.tables

      data_sources.each do |table|
        next if table.in?([ DIGEST_TABLE_NAME, 'schema_migrations' ])
        if conn.select_one("select * from #{table}")
          tables << table
        end
      end

      tables
    end
  end
end
