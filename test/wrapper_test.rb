require 'test_helper'

class WrapperTest < ActiveSupport::TestCase

  test "name compiles to just name" do
    assert_equal "foo", Gara::Components::Wrapper.new('foo').compile
  end

  test "simple args are preserved" do
    wrapper =  Gara::Components::Wrapper.new('foo', "xyzzy", 'bar', "baz", 1, false, 3)
    assert_equal 'foo("xyzzy", "bar", "baz", 1, false, 3)', wrapper.compile
  end

  test "args are preserved" do
    wrapper =  Gara::Components::Wrapper.new('foo', "xyzzy", bar: "baz")
    assert_equal 'foo("xyzzy", bar: "baz")', wrapper.compile
  end

end