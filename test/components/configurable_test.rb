require 'test_helper'

class ConfigurableTest < ActiveSupport::TestCase

  ETC = ExpressTemplates::Components

  class ConfigurableComponent < ETC::Base
    include ETC::Capabilities::Configurable
    emits {
      div.bar(my[:id])
    }
  end

  test "a configurable component accepts an id argument" do
    assert :foo, ConfigurableComponent.new(:foo).my[:id]
  end

  test "renders id argument as dom id" do
    compiled_src = ConfigurableComponent.new(:foo).compile
    assert '<div id="foo" class="bar" />', compiled_src
  end
end