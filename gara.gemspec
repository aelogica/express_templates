$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "gara/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "gara"
  s.version     = Gara::VERSION
  s.authors     = ["Steven Talcott Smith"]
  s.email       = ["steve@aelogica.com"]
  s.homepage    = "http://gara.github.io"
  s.summary     = "Write HTML templates in ruby using nokogiri."
  s.description = "Instead of Erb or HAML, write templates in plain ruby using Nokogiri."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "nokogiri"

  s.add_development_dependency "rails", "~> 4.1.4"
end
