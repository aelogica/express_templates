require 'test_helper'

class RadioTest < ActiveSupport::TestCase

  test "radio requires a parent component" do
    fragment = -> {
      radio :preferred_email_format, ['HTML', 'Text']
    }
    assert_raises(RuntimeError) {
      ExpressTemplates.compile(&fragment)
    }
  end

  def radio_with_array_options
    fragment = -> {
      express_form(:person) {
        radio :preferred_email_format, ['HTML', 'Text']
      }
    }
  end

  test "radio has correct label field name and text" do
    assert_match '#{label_tag("person_preferred_email_format", "Preferred Email Format")}',
                  ExpressTemplates.compile(&radio_with_array_options)
  end

  test "radio options present with class 'radio'" do
    compiled = ExpressTemplates.compile(&radio_with_array_options)
    assert_match 'radio_button(:person, :preferred_email_format, "Text", class: "radio"', compiled
    assert_match '_format, "HTML", class: "radio"', compiled
  end

  def radio_with_hash_options
    fragment = -> {
      express_form(:person) {
        radio :subscribed, {1 => 'Yes', 0 => 'No'}, wrapper_class: 'my-wrapper'
      }
    }
  end

  test "radio options may be specified with a hash" do
    compiled = ExpressTemplates.compile(&radio_with_hash_options)
    assert_match '<label class=\"my-wrapper\">', compiled
    assert_match 'radio_button(:person, :subscribed, 0, class: "radio"', compiled
    assert_match 'radio_button(:person, :subscribed, 1, class: "radio"', compiled
  end

  test "radio throws error if given improper options" do
    fragment = -> {
      express_form(:person) {
        radio :subscribed, "Garbage options"
      }
    }
    assert_raises(RuntimeError) {
      ExpressTemplates.compile(&fragment)
    }
  end

  def radio_with_options_omitted
    fragment = -> {
      express_form(:employee) {
        radio :department_id
      }
    }
  end

  class ::Department ; end
  class ::Employee
    def self.reflect_on_association(name)
      if name.eql? :department
        dummy_association = Object.new
        class << dummy_association
          def macro ; :belongs_to ; end
          def klass ; ::Department ; end
        end
        return dummy_association
      end
    end
  end

  test "radio options from collection when options omitted" do
    assert_match 'collection_radio_buttons(:employee, :department_id, Department.all.select(:id, :name).order(:name), :id, :name, {}, {}',
                  ExpressTemplates.compile(&radio_with_options_omitted)
  end

  # test "radio supports html options"

  # test "html_options passed correctly when collection is omitted"

  # test "radio helper options passed to collection_radio_buttons"
end
