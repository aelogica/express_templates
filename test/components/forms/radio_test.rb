require 'test_helper'

class RadioTest < ActiveSupport::TestCase

  def assigns
    {resource: resource}
  end

  test "radio requires a parent component" do
    assert_raises(RuntimeError) {
      html = arbre {
        radio :preferred_email_format, ['HTML', 'Text']
      }
    }
  end

  def radio_with_array_options
    html = arbre {
      express_form(:person) {
        radio :preferred_email_format, ['HTML', 'Text']
      }
    }
  end

  test "radio has correct label field name and text" do
    assert_match /<label for="person_preferred_email_format"/,
                  radio_with_array_options
  end

  test "radio options present with class 'radio'" do
    assert_match /<input.*class="radio"/,
                 radio_with_array_options
  end

  def radio_with_hash_options
    html = arbre {
      express_form(:person) {
        radio :subscribed, {1 => 'Yes', 0 => 'No'}, wrapper_class: 'my-wrapper'
      }
    }
  end

  test "radio options may be specified with a hash" do
    compiled = radio_with_hash_options
    assert_match '<label class="my-wrapper">', compiled
    assert_match 'input class="radio" type="radio" value="0" name="person[subscribed]" id="person_subscribed_0" />No', compiled
    assert_match 'input class="radio" type="radio" value="1" name="person[subscribed]" id="person_subscribed_1" />Yes', compiled
  end

  test "radio throws error if given improper options" do
    assert_raises(RuntimeError) {
      html = arbre {
        express_form(:person) {
          radio :subscribed, "Garbage options"
        }
      }
    }
  end

  def radio_with_options_omitted
    html = arbre {
      express_form(:employee) {
        radio :department_id
      }
    }
  end

  class ::Department < ::Gender
    def self.order(*)
      all
    end
    def self.all
      return [new(1, 'Accounting'), new(2, 'Marketing')]
    end
  end
  class ::Employee
    def self.reflect_on_association(name)
      if name.eql? :department
        dummy_association = Object.new
        class << dummy_association
          def macro ; :belongs_to ; end
          def klass ; ::Department ; end
          def polymorphic? ; false ; end
        end
        return dummy_association
      end
    end
  end

  test "radio options from collection when options omitted" do
    assert_match /input type="radio" value="1" name="employee\[department_id\]" id="employee_department_id_1"/,
                  radio_with_options_omitted
  end

  # test "radio supports html options"

  # test "html_options passed correctly when collection is omitted"

  # test "radio helper options passed to collection_radio_buttons"
end
