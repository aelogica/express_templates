$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "gara/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "gara"
  s.version     = Gara::VERSION
  s.authors     = ["Steven Talcott Smith"]
  s.email       = ["steve@aelogica.com"]
  s.homepage    = "https://github.com/aelogica/gara"
  s.summary     = "Write HTML templates in plain Ruby using Nokogiri."
  s.description = "Instead of Erb or HAML, write templates in plain Ruby using Nokogiri."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "nokogiri", "~> 1.6"

  s.add_development_dependency "rails", "~> 4.1"
  s.add_development_dependency "pry", "~> 0"

end
