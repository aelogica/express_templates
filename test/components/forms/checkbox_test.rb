require 'test_helper'

class CheckboxTest < ActiveSupport::TestCase

  test "Checkbox requires a parent form" do
    fragment = -> {
      checkbox :permission_granted
    }
    assert_raises(RuntimeError) {
      ExpressTemplates.compile(&fragment)
    }
  end

  test "checkbox places the label before the input" do
    fragment = -> {
      express_form(:account) {
        checkbox :eula
      }
    }
    compiled = ExpressTemplates.compile(&fragment)
    label_helper = '#{label_tag("account_eula", "Eula")}'
    field_helper = '#{check_box(:account, :eula, {}, "1", "0")}'
    assert_match label_helper, compiled
    assert_match field_helper, compiled
    label_idx = compiled.index(label_helper)
    field_idx = compiled.index(field_helper)
    assert (field_idx > label_idx), "label must come first"
  end

  test "checkbox respects label_after: true " do
    fragment = -> {
      express_form(:account) {
        checkbox :eula, label_after: true
      }
    }
    compiled = ExpressTemplates.compile(&fragment)
    label_helper = '#{label_tag("account_eula", "Eula")}'
    field_helper = '#{check_box(:account, :eula, {}, "1", "0")}'
    label_idx = compiled.index(label_helper)
    field_idx = compiled.index(field_helper)
    assert (field_idx < label_idx), "label must come after when label_after: true"
  end

end
