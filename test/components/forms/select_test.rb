require 'test_helper'
require 'ostruct'
class SelectTest < ActiveSupport::TestCase

  test "select requires a parent component" do
    fragment = -> {
      select :gender, ['Male', 'Female'], selected: 'Male'
    }
    assert_raises(RuntimeError) {
      ExpressTemplates.compile(&fragment)
    }
  end

  test "select comes with a label" do
    fragment = -> {
      express_form(:person) {
        select :gender
      }
    }
    assert_match '#{label_tag("person_gender", "Gender")}', ExpressTemplates.compile(&fragment)
  end

  test "select uses options_for_select when values are specified" do
    fragment = -> {
      express_form(:person) {
        select :gender, ['Male', 'Female'], selected: 'Male'
      }
    }
    assert_match 'options_for_select(["Male", "Female"], "Male")', ExpressTemplates.compile(&fragment)
  end

  test "selected option is omitted selection is taken from model" do
    fragment = -> {
      express_form(:person) {
        select :gender, ['Male', 'Female']
      }
    }
    assert_match 'options_for_select(["Male", "Female"], @person.gender)', ExpressTemplates.compile(&fragment)
  end

  test "select generates options from data when options omitted" do
    fragment = -> {
      express_form(:person) {
        select :city
      }
    }
    assert_match 'options_for_select(@person.class.distinct(:city).pluck(:city), @person.city)', ExpressTemplates.compile(&fragment)
  end

  class ::Gender
    def self.columns
      [OpenStruct.new(name: 'id'), OpenStruct.new(name: 'name')]
    end
  end
  class ::Person
    def self.reflect_on_association(name)
      if name.eql? :gender
        dummy_association = Object.new
        class << dummy_association
          def macro ; :belongs_to ; end
          def klass ; ::Gender ; end
          def polymorphic? ; false ; end
        end
        return dummy_association
      end
    end
  end

  test "select uses options_from_collect... when field is relation" do
    fragment = -> {
      express_form(:person) {
        select :gender
      }
    }

    assert_match 'options_from_collection_for_select(Gender.all.select(:id, :name).order(:name), :id, :name, @person.gender)',
                  ExpressTemplates.compile(&fragment)
  end

  test "select defaults to include_blank: true" do
    fragment = -> {
      express_form(:person) {
        select :gender
      }
    }
    assert_match 'include_blank: true', ExpressTemplates.compile(&fragment)
  end


  test "select defaults can be overridden" do
    fragment = -> {
      express_form(:person) {
        select :gender, nil, include_blank: false
      }
    }
    assert_no_match 'include_blank: true', ExpressTemplates.compile(&fragment)
  end

end