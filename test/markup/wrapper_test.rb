require 'test_helper'

class WrapperTest < ActiveSupport::TestCase

  Wrapper = ExpressTemplates::Markup::Wrapper

  test "name compiles to just name" do
    assert_equal '%Q(#{foo})', Interpolator.transform(Wrapper.new('foo').compile)
  end

  test "simple args are preserved" do
    wrapper =  Wrapper.new('foo', "xyzzy", 'bar', "baz", 1, false, 3)
    assert_equal '%Q(#{foo("xyzzy", "bar", "baz", 1, false, 3)})', Interpolator.transform(wrapper.compile)
  end

  test "args are preserved" do
    wrapper =  Wrapper.new('foo', "xyzzy", bar: "baz")
    assert_equal '%Q(#{foo("xyzzy", bar: "baz")})', Interpolator.transform(wrapper.compile)
  end

  test "something returning nil when wrapped and compiled, evals to an empty string" do
    assert_equal '', eval(Interpolator.transform(Wrapper.new('nil').compile))
  end

  test "double-braced args are evaluated in context" do
    wrapper = Wrapper.new('foo', "{{xyz}}", "{{zyx}}", bar: "baz")
    assert_equal '%Q(#{foo(xyz, zyx, bar: "baz")})', Interpolator.transform(wrapper.compile)
  end

  test "initializer block is preserved in compile" do
    wrapper = Wrapper.new('foo') { whatever }
    assert_equal '%Q(#{foo { whatever }})', Interpolator.transform(wrapper.compile)
    wrapper = Wrapper.new('foo', 'bar') { whatever }
    assert_equal '%Q(#{foo("bar") { whatever }})', Interpolator.transform(wrapper.compile)
  end

  test "lambda option values are evaluated in context" do
    wrapper = Wrapper.new('foo', bar: -> { something })
    assert_equal '%Q(#{foo(bar: (-> { something }).call)})', Interpolator.transform(wrapper.compile)
  end

end