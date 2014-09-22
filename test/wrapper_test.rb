require 'test_helper'

class WrapperTest < ActiveSupport::TestCase

  test "name compiles to just name" do
    assert_equal '"#{foo}"', ExpressTemplates::Components::Wrapper.new('foo').compile
  end

  test "simple args are preserved" do
    wrapper =  ExpressTemplates::Components::Wrapper.new('foo', "xyzzy", 'bar', "baz", 1, false, 3)
    assert_equal '"#{foo("xyzzy", "bar", "baz", 1, false, 3)}"', wrapper.compile
  end

  test "args are preserved" do
    wrapper =  ExpressTemplates::Components::Wrapper.new('foo', "xyzzy", bar: "baz")
    assert_equal '"#{foo("xyzzy", bar: "baz")}"', wrapper.compile
  end

  test "something returning nil when wrapped and compiled, evals to an empty string" do
    assert_equal '', eval(ExpressTemplates::Components::Wrapper.new('nil').compile)
  end

end