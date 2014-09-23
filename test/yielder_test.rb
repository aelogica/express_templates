require 'test_helper'

class YielderTest < ActiveSupport::TestCase

  test "yielder preserves symbol args" do
    assert_equal 'yield(:foo)', ExpressTemplates::Components::Yielder.new(:foo).compile
  end

end
