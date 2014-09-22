require 'test_helper'

class ExpanderTest < ActiveSupport::TestCase

  class Foo < ExpressTemplates::Component ; end
  class Bar < ExpressTemplates::Component ; end
  class Baz < ExpressTemplates::Component ; end

  ExpressTemplates::Expander.register_macros_for(Foo,Bar,Baz)

  test ".expand returns a string"  do
    source = "foo"
    result = ExpressTemplates::Expander.expand(nil, source)
    assert_kind_of String, result
  end

  test "#expand returns an array containing a component" do
    source = "foo"
    result = ExpressTemplates::Expander.new(nil).expand(source)
    assert_kind_of ExpressTemplates::Component, result.first
  end

  test "#expand of 'foo { foo } returns a component with a child component" do
    source = 'foo { foo }'
    result = ExpressTemplates::Expander.new(nil).expand(source)
    assert_kind_of Foo, result.first.children.first
  end

  test "#expand of 'foo { bar ; baz } returns a component with two children" do
    source = 'foo { bar ; baz }'
    result = ExpressTemplates::Expander.new(nil).expand(source)
    assert_equal 2, result.first.children.size
    assert_kind_of Bar, result.first.children.first
    assert_kind_of Baz, result.first.children.last
  end

  test "#expand of macros with args returns a component with two children" do
    source = 'foo { bar(fiz: "buzz") ; baz }'
    result = ExpressTemplates::Expander.new(nil).expand(source)
    assert_equal 2, result.first.children.size
    assert_kind_of Bar, result.first.children.first
    assert_kind_of Baz, result.first.children.last
  end

  test "#expand correctly allocated helpers and parameters xxx" do
    source = 'helper ; foo { buzz }'
    result = ExpressTemplates::Expander.new(nil).expand(source)
    assert_equal 0, result.first.children.size
    assert_equal 1, result[1].children.size
    assert_kind_of ExpressTemplates::Components::Wrapper, result.first
    assert_kind_of Foo, result[1]
    assert_kind_of ExpressTemplates::Components::Wrapper, result[1].children.first
  end


end