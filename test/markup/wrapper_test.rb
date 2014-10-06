require 'test_helper'

class WrapperTest < ActiveSupport::TestCase

  test "name compiles to just name" do
    assert_equal '"#{foo}"', ExpressTemplates::Markup::Wrapper.new('foo').compile
  end

  test "simple args are preserved" do
    wrapper =  ExpressTemplates::Markup::Wrapper.new('foo', "xyzzy", 'bar', "baz", 1, false, 3)
    assert_equal '"#{foo("xyzzy", "bar", "baz", 1, false, 3)}"', wrapper.compile
  end

  test "args are preserved" do
    wrapper =  ExpressTemplates::Markup::Wrapper.new('foo', "xyzzy", bar: "baz")
    assert_equal '"#{foo("xyzzy", bar: "baz")}"', wrapper.compile
  end

  test "something returning nil when wrapped and compiled, evals to an empty string" do
    assert_equal '', eval(ExpressTemplates::Markup::Wrapper.new('nil').compile)
  end

  test "double-braced args are evaluated in context" do
    wrapper = ExpressTemplates::Markup::Wrapper.new('foo', "{{xyz}}", "{{zyx}}", bar: "baz")
    assert_equal '"#{foo(xyz, zyx, bar: "baz")}"', wrapper.compile
  end

end