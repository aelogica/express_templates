require 'test_helper'
require 'ostruct'
class SelectTest < ActiveSupport::TestCase

  def assigns
    {resource: ::Person.new}
  end


  test "select requires a parent component" do
    assert_raises(RuntimeError) {
      html = arbre {
        select :gender, options: ['Male', 'Female'], selected: 'Male'
      }
    }
  end

  test "select comes with a label" do
    html = arbre {
      express_form(:person) {
        select :gender
      }
    }
    assert_match /<label.*for="person_gender"/, html
  end

  test "select generates correct options when values are specified as array" do
    html = arbre {
      express_form(:person) {
        select :gender, options: ['Male', 'Female'], selected: 'Male'
      }
    }
    assert_match /<option.*selected="selected" value="Male"/, html
    assert_match /<option.*value="Female"/, html
  end

  test "selected option is omitted selection is taken from model" do
    html = arbre {
      express_form(:person) {
        select :gender, options: ['Male', 'Female']
      }
    }
    assert_match /<option.*selected="selected" value="Male"/, html
    assert_match /<option.*value="Female"/, html
  end

  test "select generates options from data when options omitted" do
    html = arbre {
      express_form(:person) {
        select :city
      }
    }
    assert_match /<option.*selected="selected" value="San Francisco"/, html
    assert_match /<option.*value="Hong Kong"/, html
  end

  test "select uses options_from_collect... when field is relation" do
    html = arbre {
      express_form(:person) {
        select :gender_id
      }
    }

    assert_match /<option.*selected="selected" value="1"/, html
    assert_match /<option.*value="2"/, html
  end

  test "select defaults to include_blank: true" do
    html = arbre {
      express_form(:person) {
        select :gender
      }
    }
    assert_match '<option value=""></option>', html
  end


  test "select defaults can be overridden" do
    html = arbre {
      express_form(:person) {
        select :gender, include_blank: false
      }
    }
    assert_no_match 'include_blank: true', html
  end

  test "select multiple: true if passed multiple true" do
    html = arbre {
      express_form(:person) {
        select :taggings, include_blank: false, multiple: true
      }
    }
    assert_match 'multiple="multiple"', html
  end

  test "select multiple gets options from associated has_many_through collection" do
    html = arbre {
      express_form(:person) {
        select :taggings, include_blank: false, multiple: true
      }
    }
    assert_match 'tagging_ids', html
    assert_match /<option selected="selected" value="1">Friend<\/option>/, html
    assert_match /<option selected="selected" value="2">Enemy<\/option>/, html
    assert_match /<option value="3">Frenemy<\/option>/, html
  end

  test "select_collection works using collection_select" do
    html = arbre {
      express_form(:person) {
        select_collection :taggings
      }
    }
    assert_match 'tagging_ids', html
    assert_match /<option value="1">Friend<\/option>/, html
    assert_match /<option value="2">Enemy<\/option>/, html
    assert_match /<option value="3">Frenemy<\/option>/, html
  end


end