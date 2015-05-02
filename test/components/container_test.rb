require 'test_helper'
require 'minitest/mock'

class ContainerTest < ActiveSupport::TestCase

  ETC = ExpressTemplates::Components

  def any_container
    Class.new(ETC::Container)
  end

  test "a Container is a Component" do
    assert_kind_of ETC::Base, any_container.new
  end

  test "a container has children but initially has none" do
    assert any_container.new.respond_to?(:children)
    assert_equal [], any_container.new.children
  end

  def mock_children(parent)
    child1, child2 = Minitest::Mock.new, Minitest::Mock.new
    child1.expect(:compile, '"one"')
    child2.expect(:compile, '"two"')
    child1.expect(:instance_variable_set, parent, [:@parent, parent])
    child2.expect(:instance_variable_set, parent, [:@parent, parent])
    return child1, child2
  end

  class TestContainer < ETC::Container
    emits -> { p { _yield } }
  end

  test "Container#compile calls #compile on its children; children have references to their parent" do
    container = TestContainer.new
    child1, child2 = mock_children(container)
    container.children = [child1, child2]
    container.compile
    child1.verify
    child2.verify
  end

  test "renders children in place of _yield" do
    container = TestContainer.new
    child1, child2 = mock_children(container)
    container.children = [child1, child2]

    assert_equal "<p>onetwo</p>", eval(container.compile)
  end

  class Context
    def a_helper
      "foo"
    end
  end

  test "children with interpolations" do
    markup = ExpressTemplates.render(Context.new) do
      row {
        p %q(Should say: {{a_helper}}.)
      }
    end
    assert_equal "<div class=\"row\"><p>Should say: foo.</p></div>", markup
  end

end