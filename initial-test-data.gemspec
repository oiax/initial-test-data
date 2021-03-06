version = File.read(File.expand_path("../VERSION",__FILE__)).strip

Gem::Specification.new do |s|
  s.name        = "initial-test-data"
  s.version     = version
  s.authors     = [ "Tsutomu KURODA" ]
  s.email       = "t-kuroda@oiax.jp"
  s.homepage    = "https://github.com/oiax/initial-test-data"
  s.description = "initial-test-data provides a way to create a test fixture using Active Record, Factory Girl, etc."
  s.summary     = "Test fixture creation tool"
  s.license     = "MIT"

  s.required_ruby_version = ">= 2.0"

  s.add_dependency "activesupport", ">= 3.0", "< 6.0"
  s.add_dependency "activerecord", ">= 3.0", "< 6.0"
  s.add_dependency "railties", ">= 3.0", "< 6.0"
  s.add_dependency "database_cleaner", "~> 1.5"
  s.add_development_dependency "sqlite3", "~> 1.3"
  s.add_development_dependency "factory_girl", "~> 4.5"

  s.files = %w(CHANGELOG.md README.md MIT-LICENSE) + Dir.glob("lib/**/*")
end
