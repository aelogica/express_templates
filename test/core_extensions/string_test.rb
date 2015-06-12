require 'test_helper'

class StringTest < ActiveSupport::TestCase
  def string
    "@resource.something"
  end

  test "String#to_view_code returns the string" do
    assert_equal  string, string.to_view_code
  end

  test "String#inspect works normally when #to_view_code hasn't been called" do
    assert_equal  %Q("#{string}"), string.inspect
  end

  test "String#to_view_code causes subsequent #inspect to remove quotes" do
    assert_equal  string, string.to_view_code.inspect
  end

end