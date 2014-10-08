require 'test_helper'

class RowTest < ActiveSupport::TestCase

  ETC = ExpressTemplates::Components

  test "a row is configurable" do
    assert ETC::Row.ancestors.include?(ETC::Capabilities::Configurable)
  end

end