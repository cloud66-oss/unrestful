$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "unrestful/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "unrestful"
  s.version     = Unrestful::VERSION
  s.authors     = ["Khash Sajadi"]
  s.email       = ["khash@cloud66.com"]
  s.homepage    = "https://github.com/khash/unrestful"
  s.summary     = "Unrestful is a simple RPC framework for Rails"
  s.description = "Sometimes you need an API but not a RESTful one. You also don't want the whole gRPC or Thrift stack in your Rails app. Unrestful is the answer!"
  s.license     = "Apache-2.0"
  
  s.files = Dir["{app,config,db,lib}/**/*", "APACHE-LICENSE", "Rakefile", "README.md"]
  
  s.add_dependency 'rails', '~> 5.2.0'
  s.add_dependency 'jwt', '~> 2.2'
  s.add_dependency 'redis', '~> 4.1'

  s.add_development_dependency 'puma'
  s.add_development_dependency 'sqlite3'
end
