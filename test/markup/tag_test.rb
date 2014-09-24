require 'test_helper'

class TagTest < ActiveSupport::TestCase

  class Bare < ExpressTemplates::Markup::Tag ; end
  class Sub < ExpressTemplates::Markup::Tag ; end

  def bare_component(*args)
    Bare.new(*args)
  end

  def sub_component(*args)
    Sub.new(*args)
  end


  test "#macro_name returns the name of the class" do
    assert_equal 'bare', bare_component.macro_name
  end

  test "#compile returns a string" do
    assert_kind_of String, bare_component.compile
  end

  test "has no children" do
    assert_empty bare_component.children
  end

  def bare_with_2_children
    component = bare_component "child1", "child2"
  end

  test "can be created with children" do
    assert_equal 2, bare_with_2_children.children.size
    assert_equal "child2", bare_with_2_children.children.last
  end

  test "#compile on bare_with_2_children yields '\"<bare>\"+\"child1\"+\"child2\"+\"</bare>\"'" do
    assert_equal '"<bare>"+"child1"+"child2"+"</bare>"', bare_with_2_children.compile
  end

  test "#start_tag is my macro_name as an xml start tag" do
    assert_equal "<#{bare_component.macro_name}>", bare_component.start_tag
  end

  test "#close_tag is my macro_name as an xml close tag" do
    assert_equal "</#{bare_component.macro_name}>", bare_component.close_tag
  end

  def component_with_subcomponent
    bare_component sub_component
  end

  test "#compile on component_with_subcomponent returns a string which when eval'd looks like '<bare><sub></sub></bare>'" do
    assert_equal '<bare><sub></sub></bare>', eval(component_with_subcomponent.compile)
  end

  test "#to_template on bare_component returns 'bare'" do
    assert_equal 'bare', bare_component.to_template
  end

  test "#to_template on component_with_subcomponent returns 'bare {\n  sub\n}\n'" do
    assert_equal "bare {\n  sub\n}\n", component_with_subcomponent.to_template
  end

  test "#to_template on nested components indents properly'" do
    expected = %Q(bare {
  sub {
    sub
  }
}
)
    assert_equal expected, Bare.new(Sub.new(Sub.new)).to_template
  end

  # test "proc option values are evaluated"

  # test "hash option values are converted to json"


end