require 'test_helper'

class Stuff
  def self.columns
    []
  end
end

class SubmitTest < ActiveSupport::TestCase
  test "submit takes string param for value" do
    fragment = -> (ctx) {
      submit "Save it!"
    }
    assert_match '<div class="field-wrapper"><input type="submit" name="commit" value="Save it!" /></div>', 
                 arbre(&fragment)
  end
end
