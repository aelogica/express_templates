# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

require 'pry'
require 'minitest/reporters'
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
end

ECB = ExpressTemplates::Components::Base
ETC = ExpressTemplates::Components
ET = ExpressTemplates
Interpolator = ExpressTemplates::Interpolator

require 'arbre'
Tag = Arbre::HTML::Tag

ENV["ET_NO_INDENT_MARKUP"] = 'true'
