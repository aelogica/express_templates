$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "express_templates/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "express_templates"
  s.version     = ExpressTemplates::VERSION
  s.authors     = ["Steven Talcott Smith"]
  s.email       = ["steve@aelogica.com"]
  s.homepage    = "https://github.com/aelogica/express_templates"
  s.summary     = "Write HTML templates in declarative Ruby.  Create reusable view components."
  s.description = "Replace Erb/HAML/Slim with ExpressTemplates and write templates in a declartive style of Ruby.  With ExpressTemplates you may easily create a library of components for use across projects."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "activesupport", "~> 4.1" # strictly speaking we only depend on active support
  s.add_development_dependency "rails", "~> 4.1"
  s.add_development_dependency "pry", "~> 0"
  s.add_development_dependency "erubis", "~> 2.7"
  s.add_development_dependency "haml", "~> 4.0"
  s.add_development_dependency "better_errors", "~> 2.0"
  s.add_development_dependency "binding_of_caller", "~> 0.7"
end
