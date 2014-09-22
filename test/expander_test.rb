require 'test_helper'

class ExpanderTest < ActiveSupport::TestCase

  class Foo < Gara::Component ; end
  class Bar < Gara::Component ; end
  class Baz < Gara::Component ; end

  Gara::Expander.register_macros_for(Foo,Bar,Baz)

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
    assert_kind_of Foo, result.first.children.first
  end

  test "#expand of 'foo { bar ; baz } returns a component with two children" do
    source = 'foo { bar ; baz }'
    result = Gara::Expander.new(nil).expand(source)
    assert_equal 2, result.first.children.size
    assert_kind_of Bar, result.first.children.first
    assert_kind_of Baz, result.first.children.last
  end

  test "#expand of macros with args returns a component with two children" do
    source = 'foo { bar(fiz: "buzz") ; baz }'
    result = Gara::Expander.new(nil).expand(source)
    assert_equal 2, result.first.children.size
    assert_kind_of Bar, result.first.children.first
    assert_kind_of Baz, result.first.children.last
  end

  test "#expand correctly allocated helpers and parameters xxx" do
    source = 'helper ; foo { buzz }'
    result = Gara::Expander.new(nil).expand(source)
    assert_equal 0, result.first.children.size
    assert_equal 1, result[1].children.size
    assert_kind_of Gara::Components::Wrapper, result.first
    assert_kind_of Foo, result[1]
    assert_kind_of Gara::Components::Wrapper, result[1].children.first
  end


end