require 'test_helper'

class GaraTest < ActiveSupport::TestCase
  test "we have a module" do
    assert_kind_of Module, Gara
  end

  test "Gara.render renders a template" do
    result = Gara.render(self) do
      ul {
        li 'one'
        li 'two'
        li 'three'
      }
    end
    assert_equal "<ul><li>one</li><li>two</li><li>three</li></ul>", result
  end

end
