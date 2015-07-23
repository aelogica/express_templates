require 'test_helper'

class Stuff
  def self.columns
    []
  end
end

class SubmitTest < ActiveSupport::TestCase
  test "submit takes string param for value" do
    fragment = -> (ctx) {
      submit value: "Save it!"
    }
    assert_match '<div class="field-wrapper"><input type="submit" name="commit" value="Save it!" /></div>',
                 arbre(&fragment)
  end
  test "submit accepts a class option" do
    fragment = -> (ctx) {
      submit class: 'button'
    }
    assert_match '<div class="field-wrapper"><input type="submit" name="commit" value="Save" class="button" /></div>',
                 arbre(&fragment)
  end
  test "submit accepts a value and class option" do
    fragment = -> (ctx) {
      submit value: 'XYZ', class: 'button'
    }
    assert_match '<div class="field-wrapper"><input type="submit" name="commit" value="XYZ" class="button" /></div>',
                 arbre(&fragment)
  end

end
