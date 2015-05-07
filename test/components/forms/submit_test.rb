require 'test_helper'

class SubmitTest < ActiveSupport::TestCase
  test "submit takes string param for value" do
    fragment = -> {
      express_form(:stuff) {
        submit "Save it!"
      }
    }
    assert_match '#{submit_tag("Save it!", {})}', ExpressTemplates.compile(&fragment)
  end
end
