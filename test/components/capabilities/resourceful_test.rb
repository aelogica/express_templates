require 'test_helper'

module AdminModule
  module Engine
  end
  class SmartThing
    include ExpressTemplates::Components::Capabilities::Resourceful

    attr_accessor :virtual_path, :config

    def initialize(virtual_path, config = {})
      @virtual_path = virtual_path
      @config = config
      @args = [self]
    end

    def template_virtual_path
      @virtual_path
    end
  end
end

module Admin; end

class FooBar; end

class Something; end

module ExpressTemplates

  class ResourcefulTest < ActiveSupport::TestCase
    test 'infers namespace and path prefix within an engine and scope' do
      smart_thing = AdminModule::SmartThing.new('admin_module/admin/something/index')
      assert_equal 'admin_module', smart_thing.namespace
      assert_equal 'admin', smart_thing.path_prefix
    end

    test 'infers a namespace and no prefix within an engine' do
      # if defined? ExpressFoo::Engine
      smart_thing = AdminModule::SmartThing.new('admin_module/something/index')
      assert_equal 'admin_module', smart_thing.namespace
      assert_equal nil, smart_thing.path_prefix
    end

    test 'no namespace, infers prefix within a scope within an app' do
      # else of case above
      smart_thing = AdminModule::SmartThing.new('admin/something/index')
      assert_equal nil, smart_thing.namespace
      assert_equal 'admin', smart_thing.path_prefix
    end

    test 'no namespace, no prefix within an app' do
      smart_thing = AdminModule::SmartThing.new('somethings/index')
      assert_equal nil, smart_thing.namespace
      assert_equal nil, smart_thing.path_prefix
    end

    test "#resource_class returns resource_class option if specified" do
      assert_equal FooBar, AdminModule::SmartThing.new('somethings/index', resource_class: 'FooBar').resource_class
      assert_equal Something, AdminModule::SmartThing.new('somethings/index', id: :something).resource_class
    end
  end
end
