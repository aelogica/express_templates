require 'test_helper'

class CompilerTest < ActiveSupport::TestCase
  test ".compile returns a string"  do
    source = "h1"
    result = ExpressTemplates.compile(source)
    assert_kind_of String, result
  end
end