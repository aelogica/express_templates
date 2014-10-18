require 'test_helper'

class ExpressTemplatesTest < ActiveSupport::TestCase
  test "we have a module" do
    assert_kind_of Module, ExpressTemplates
  end

  test "ExpressTemplates.render renders a template" do
    result = ExpressTemplates.render(self) do
      ul {
        li 'one'
        li 'two'
        li 'three'
      }
    end
    assert_equal "<ul><li>one</li><li>two</li><li>three</li></ul>", result
  end

end
