require 'test_helper'

class ExpressTemplatesTest < ActiveSupport::TestCase
  test "we have a module" do
    assert_kind_of Module, ExpressTemplates
  end

  def assigns
    {}
  end

  test "ExpressTemplates.render renders a template" do
    result = ExpressTemplates.render(self) do
      ul {
        li 'one'
        li 'two'
        li 'three'
      }
    end
    assert_equal "<ul>\n  <li>one</li>\n  <li>two</li>\n  <li>three</li>\n</ul>\n", result
  end

end
