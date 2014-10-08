require 'test_helper'

class TagTest < ActiveSupport::TestCase

  class Bare < ExpressTemplates::Markup::Tag ; end
  class Sub < ExpressTemplates::Markup::Tag ; end

  def bare_tag(*args)
    Bare.new(*args)
  end

  def sub_tag(*args)
    Sub.new(*args)
  end


  test "#macro_name returns the name of the class" do
    assert_equal 'bare', bare_tag.macro_name
  end

  test "#compile returns a string" do
    assert_kind_of String, bare_tag.compile
  end

  test "has no children" do
    assert_empty bare_tag.children
  end

  def bare_with_2_children
    tag = bare_tag "child1", "child2"
  end

  test "can be created with children" do
    assert_equal 2, bare_with_2_children.children.size
    assert_equal "child2", bare_with_2_children.children.last
  end

  test "#compile on bare_with_2_children yields '\"<bare>\"+\"child1\"+\"child2\"+\"</bare>\"'" do
    assert_equal '"<bare>"+"child1"+"child2"+"</bare>"', bare_with_2_children.compile
  end

  test "#start_tag is my macro_name as an xml start tag" do
    assert_equal "<#{bare_tag.macro_name}>", bare_tag.start_tag
  end

  test "#close_tag is my macro_name as an xml close tag" do
    assert_equal "</#{bare_tag.macro_name}>", bare_tag.close_tag
  end

  def tag_with_subtag
    bare_tag sub_tag
  end

  test "#compile on tag_with_subtag returns a string which when eval'd looks like '<bare><sub></sub></bare>'" do
    assert_equal '<bare><sub /></bare>', eval(tag_with_subtag.compile)
  end

  test "#to_template on bare_tag returns 'bare'" do
    assert_equal 'bare', bare_tag.to_template
  end

  test "#to_template on tag_with_subtag returns 'bare {\n  sub\n}\n'" do
    assert_equal "bare {\n  sub\n}\n", tag_with_subtag.to_template
  end

  test "#to_template on nested tags indents properly'" do
    expected = %Q(bare {
  sub {
    sub
  }
}
)
    assert_equal expected, Bare.new(Sub.new(Sub.new)).to_template
  end

  test "double bracketed option values are substituted for evaluation in context" do
    assert_equal '"<bare should_eval_in_context=\"#{foo}\" />"', bare_tag(should_eval_in_context: "{{foo}}").compile
  end

  test "double bracketed child values are substituted for evaluation in context" do
    assert_equal '"<bare>"+"#{foo}"+"</bare>"', bare_tag("{{foo}}").compile
  end

  test "data option value hashes are converted to data attributes similar to haml" do
    assert_equal %("<bare data-one=\\"two\\" data-three=\\"four\\" />"),
                 bare_tag(data: {one: 'two', three: 'four'}).compile
  end

  test "data option value hashes can take immediate values" do
    assert_equal %("<bare data-foo=\\"true\\" data-bar=\\"42\\" data-baz=\\"blah\\" />"),
                 bare_tag(data: {foo: true, bar: 42, baz: 'blah'}).compile
  end


  # todo?
  # test "proc option values are evaluated in context"

  test "empty tags use abbreviated empty tag form" do
    assert_equal '"<bare />"', bare_tag.compile
  end

  test "empty i tag does does not use abbreviated form since it is used for icons" do
    assert_equal '"<i>"+"</i>"', ExpressTemplates::Markup::I.new.compile
  end

  test "method missing returns self" do
    tag = bare_tag
    assert_equal tag, tag.foo
  end

  # the block form of this is tested in expander
  test "children still evaluated after css class provided via method syntax" do
    assert_equal '"<bare class=\"foo\">"+"<sub />"+"</bare>"', (bare_tag.foo(sub_tag)).compile
  end

  test "CSS classes specified with underscored method get translated to dashed" do
    assert_equal '"<bare class=\"foo-bar\" />"', bare_tag._foo_bar.compile
  end

  test "dom ID may be passed as a symbol" do
    assert_equal '"<bare id=\"foo\" />"', bare_tag(:foo).compile
  end

  # test "hash option values are converted to json"


end