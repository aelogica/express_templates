require 'test_helper'

class ConfigurableTest < ActiveSupport::TestCase

  ETC = ExpressTemplates::Components

  # class ConfigurableComponent < ETC::Base
  #   include ETC::Capabilities::Configurable
  #   emits {
  #     div.bar(my[:id])
  #   }
  # end

  # test "a configurable component accepts an id argument" do
  #   assert :foo, ConfigurableComponent.new(:foo).my[:id]
  # end

  # test "renders id argument as dom id" do
  #   compiled_src = ConfigurableComponent.new(:foo).compile
  #   assert '<div id="foo" class="bar" />', compiled_src
  # end

  class ConfigurableContainerComponent < ETC::Base
    include ETC::Capabilities::Configurable
    include ETC::Capabilities::Parenting
    emits {
      div(my[:id]) {
        _yield
      }
    }
  end

  test "a configurable component may have also be a container" do
    html = ExpressTemplates.render { configurable_container_component(:foo) { p "bar" }}
    assert_equal '<div id="foo"><p>bar</p></div>', html
  end

end