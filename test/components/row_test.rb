require 'test_helper'

class RowTest < ActiveSupport::TestCase

  ETC = ExpressTemplates::Components

  test "a row is configurable" do
    assert ETC::Row.ancestors.include?(ETC::Capabilities::Configurable)
  end

  test "id is optional" do
    compiled_src = ETC::Row.new(nil).compile
    assert_equal '<div class="row"></div>', eval(compiled_src)
  end

end