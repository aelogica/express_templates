require 'test_helper'

class NullWrapTest < ActiveSupport::TestCase

  ETC = ExpressTemplates::Components

  test "a NullWrap is a Container" do
    assert ETC::NullWrap.ancestors.include?(ETC::Capabilities::Parenting)
  end

  test "null_wrap accepts a string contianing a ruby string def" do
    compiled_src = ETC::NullWrap.new("%q(<p>whatever<p>)").compile
    assert_equal '<p>whatever<p>', eval(compiled_src)
  end

  test "null_wrap wraps template code" do
    fragment = -> {
      null_wrap {
        p {
          "whatever"
        }
      }
    }
    assert_equal '<p>whatever</p>', eval(ExpressTemplates.compile(&fragment))
  end


end