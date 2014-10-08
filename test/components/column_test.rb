require 'test_helper'

class ColumnTest < ActiveSupport::TestCase

  ETC = ExpressTemplates::Components

  test "a column is configurable" do
    assert ETC::Column.ancestors.include?(ETC::Capabilities::Configurable)
  end

end