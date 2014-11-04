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

  def mock_children
    child1, child2 = Minitest::Mock.new, Minitest::Mock.new
    child1.expect(:compile, '"one"')
    child2.expect(:compile, '"two"')
    return child1, child2
  end

  class TestContainer < ETC::Container
    emits -> { p { _yield } }
  end

  test "Container#compile calls #compile on its children" do
    container = TestContainer.new
    child1, child2 = mock_children
    container.children = [child1, child2]
    container.compile
    child1.verify
    child2.verify
  end

  test ".render_with_children renders children in place of _yield" do
    container = TestContainer.new
    child1, child2 = mock_children
    container.children = [child1, child2]

    assert_equal "<p>onetwo</p>", eval(container.compile)
  end

end