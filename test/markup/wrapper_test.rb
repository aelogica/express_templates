require 'test_helper'

class WrapperTest < ActiveSupport::TestCase

  Wrapper = ExpressTemplates::Markup::Wrapper

  test "name compiles to just name" do
    assert_equal '"#{foo}"', Wrapper.new('foo').compile
  end

  test "simple args are preserved" do
    wrapper =  Wrapper.new('foo', "xyzzy", 'bar', "baz", 1, false, 3)
    assert_equal '"#{foo("xyzzy", "bar", "baz", 1, false, 3)}"', wrapper.compile
  end

  test "args are preserved" do
    wrapper =  Wrapper.new('foo', "xyzzy", bar: "baz")
    assert_equal '"#{foo("xyzzy", bar: "baz")}"', wrapper.compile
  end

  test "something returning nil when wrapped and compiled, evals to an empty string" do
    assert_equal '', eval(Wrapper.new('nil').compile)
  end

  test "double-braced args are evaluated in context" do
    wrapper = Wrapper.new('foo', "{{xyz}}", "{{zyx}}", bar: "baz")
    assert_equal '"#{foo(xyz, zyx, bar: "baz")}"', wrapper.compile
  end

  test "initializer block is preserved in compile" do
    wrapper = Wrapper.new('foo') { whatever }
    assert_equal '"#{foo { whatever }}"', wrapper.compile
    wrapper = Wrapper.new('foo', 'bar') { whatever }
    assert_equal '"#{foo("bar") { whatever }}"', wrapper.compile
  end

  test "lambda option values are evaluated in context" do
    wrapper = Wrapper.new('foo', bar: -> { something })
    assert_equal '"#{foo(bar: (-> { something }).call)}"', wrapper.compile
  end

end