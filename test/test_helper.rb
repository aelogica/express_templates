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

module AdditionalHelpers

  def protect_against_forgery?
    true
  end

  def form_authenticity_token
    "AUTH_TOKEN"
  end

end



module ActiveSupport
  class TestCase
    def arbre(additional_assigns = {}, &block)
      Arbre::Context.new assigns.merge(additional_assigns), helpers, &block
    end
    def assigns
      @arbre_assigns ||={}
    end
    def helpers
      mock_action_view
    end
    def mock_action_view &block
      controller = ActionView::TestCase::TestController.new
      ActionView::Base.send :include, ActionView::Helpers
      ActionView::Base.send :include, ActionView::Helpers::UrlHelper
      ActionView::Base.send :include, AdditionalHelpers
      view = ActionView::Base.new(ActionController::Base.view_paths, assigns, controller)
      eigenklass = class << view; self; end
      eigenklass.class_eval &block unless block.nil?
      view
    end

    def resource(persisted = true)
      @resource ||= OpenStruct.new(
        id: 1,
        name: 'Foo',
        body: 'Hello world',
        email: 'some@email.com',
        phone: '123123123',
        url: 'http://someurl.com',
        number: 123,
        dropdown: 'yes',
        gender: 'Male'
      )
    end

  end
end



  class ::Gender
    attr :id, :name
    def initialize(id, name)
      @id, @name = id, name
    end
    def self.columns
      [OpenStruct.new(name: 'id'), OpenStruct.new(name: 'name')]
    end
    def self.distinct(field)
      return self #dummy
    end
    def self.pluck(*fields)
      return ['Male', 'Female']
    end
    def self.select(*)
      return self
    end
    def self.order(*)
      all
    end
    def self.all
      return [new(1, 'Male'), new(2, 'Female')]
    end
  end
  class ::Tagging
    attr :id, :name
    def initialize(id, name)
      @id, @name = id, name
    end
    def self.columns
      [OpenStruct.new(name: 'id'), OpenStruct.new(name: 'name')]
    end
    def self.select(*)
      return self
    end
    def self.order(*)
      all
    end
    def self.all
      return [new(1, 'Friend'), new(2, 'Enemy'), new(3, 'Frenemy')]
    end
  end
  class ::Person
    attr :id, :city, :subscribed, :preferred_email_format, :country_code
    def initialize(id = 1, city = 'San Francisco')
      @id, @city = id, city
    end
    def gender
      ::Gender.new(1, 'Male')
    end
    def self.reflect_on_association(name)
      if name.eql? :gender
        dummy_belongs_to_association = Object.new
        class << dummy_belongs_to_association
          def macro ; :belongs_to ; end
          def klass ; ::Gender ; end
          def polymorphic? ; false ; end
        end
        return dummy_belongs_to_association
      end
      if name.eql? :taggings
        dummy_has_many_through_association = Object.new
        class << dummy_has_many_through_association
          def macro ; :has_many ; end
          def klass ; ::Tagging ; end
          def options ; {:through => :peron_tags} ; end
          def polymorphic? ; false ; end
        end
        return dummy_has_many_through_association
      end
    end
    def taggings
      ::Tagging.all.slice(0..1)
    end
    def tagging_ids
      [1, 2]
    end
    def self.distinct(field)
      return self #dummy
    end
    def self.pluck(*fields)
      return ['Manila', 'Hong Kong', 'San Francisco']
    end
    def gender  # not really
      'Male'
    end
    def gender_id
      1
    end
    def persisted?
      false
    end
  end
