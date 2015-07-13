require 'test_helper'

class CheckboxTest < ActiveSupport::TestCase
  def assigns
    {resource: resource}
  end

  test "checkbox places the label before the input" do
    html = arbre {
      express_form(:account) {
        checkbox :eula
      }
    }
    label = '<label for="account_eula"'
    field = 'input type="checkbox" value="1" name="account\[eula\]"'
    assert_match /#{label}/, html
    assert_match /#{field}/, html
    label_idx = html.index(label)
    field_idx = html.index(field.gsub('\\', ''))
    assert (field_idx > label_idx), "label must come first"
  end

  test "checkbox respects label_after: true " do
    html = arbre {
      express_form(:account) {
        checkbox :eula, label_after: true
      }
    }
    label = '<label for="account_eula"'
    field = 'input type="checkbox" value="1" name="account\[eula\]"'
    assert_match /#{label}/, html
    assert_match /#{field}/, html
    label_idx = html.index(label)
    field_idx = html.index(field.gsub('\\', ''))
    assert (field_idx < label_idx), "label must come after when label_after: true"
  end

end
