require 'test_helper'

class ExpanderTest < ActiveSupport::TestCase

  class Gara::Components::Foo < Gara::Component ; end
  class Gara::Components::Bar < Gara::Component ; end
  class Gara::Components::Baz < Gara::Component ; end

  test ".expand returns a string"  do
    source = "foo"
    result = Gara::Expander.expand(nil, source)
    assert_kind_of String, result
  end

  test "#expand returns an array containing a component" do
    source = "foo"
    result = Gara::Expander.new(nil).expand(source)
    assert_kind_of Gara::Component, result.first
  end

  test "#expand of 'foo { foo } returns a component with a child component" do
    source = 'foo { foo }'
    result = Gara::Expander.new(nil).expand(source)
    assert_kind_of Gara::Components::Foo, result.first.children.first
  end

  test "#expand of 'foo { bar ; baz } returns a component with two children" do
    source = 'foo { bar ; baz }'
    result = Gara::Expander.new(nil).expand(source)
    assert_equal 2, result.first.children.size
    assert_kind_of Gara::Components::Bar, result.first.children.first
    assert_kind_of Gara::Components::Baz, result.first.children.last
  end

  test "#expand of macros with args returns a component with two children" do
    source = 'foo { bar ; baz }'
    result = Gara::Expander.new(nil).expand(source)
    assert_equal 2, result.first.children.size
    assert_kind_of Gara::Components::Bar, result.first.children.first
    assert_kind_of Gara::Components::Baz, result.first.children.last
  end


end