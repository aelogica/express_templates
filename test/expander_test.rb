require 'test_helper'

class ExpanderTest < ActiveSupport::TestCase

  class Foo < ExpressTemplates::Markup::Tag ; end
  class Bar < ExpressTemplates::Markup::Tag ; end
  class Baz < ExpressTemplates::Markup::Tag ; end

  ExpressTemplates::Expander.register_macros_for(Foo,Bar,Baz)

  test "#expand returns an array containing a component" do
    source = "foo"
    result = ExpressTemplates::Expander.new(nil).expand(source)
    assert_kind_of ExpressTemplates::Markup::Tag, result.first
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

  test "#expand correctly allocated helpers and parameters" do
    source = 'helper ; foo { buzz }'
    result = ExpressTemplates::Expander.new(nil).expand(source)
    assert_equal 0, result.first.children.size
    assert_equal 1, result[1].children.size
    assert_kind_of ExpressTemplates::Markup::Wrapper, result.first
    assert_kind_of Foo, result[1]
    assert_kind_of ExpressTemplates::Markup::Wrapper, result[1].children.first
  end

  test "#expand works with css class specification syntax xxx" do
    source = 'foo.active { baz }'
    result = ExpressTemplates::Expander.new(nil).expand(source)
    assert_equal 1, result[0].children.size
  end

  test "#expand doesn't yield [] for children" do
    source = %Q(ul(class: 'title-area') {
  li.name {
    a("Something", href: '#', disabled: true)
  }
  li(class:"ugly markup") {
    a(href: "#") { span "menu item" }
  }
})
    result = ExpressTemplates::Expander.new(nil).expand(source)
    child_of_first_child = result.first.children.first
    assert_equal 1, child_of_first_child.children.size
    assert_kind_of ExpressTemplates::Markup::Tag, child_of_first_child.children.first
  end

  class Special
    def self.render(label)
      :dummy
    end
  end

  test "initializer accepts special handlers hash" do
    source = "render(:markup)"
    assert_equal [:dummy], ExpressTemplates::Expander.new(nil, render: Special).expand(source)
  end
  # test "control flow"

  # test "helpers can take blocks" 
  # do
  #   source = "helper do foo ; end"
  #   result = ExpressTemplates::Expander.new(nil).expand(source)
  # end


end