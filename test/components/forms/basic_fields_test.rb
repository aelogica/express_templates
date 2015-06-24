require 'test_helper'

class BasicFieldsTest < ActiveSupport::TestCase

  BASIC_FIELDS = %w(email phone text password color date datetime
                    datetime_local number range
                    search telephone time url week)

  test "text requires parent" do
    fragment = -> {
      text :name
    }
    assert_raises(RuntimeError) {
      ExpressTemplates.compile(&fragment)
    }
  end

  test "all fields work" do
    BASIC_FIELDS.each do |type|
      fragment = -> {
        express_form(:foo) {
          send(type, :bar)
        }
      }
      assert_match '#{label_tag("foo_bar", "Bar")', ExpressTemplates.compile(&fragment)
      assert_match "#{type}_field(:foo, :bar, {})", ExpressTemplates.compile(&fragment)
    end
  end

  test "passing html options to fields work" do
    options = {class: 'form-field'}
    BASIC_FIELDS.each do |type|
      fragment = -> {
        express_form(:foo) {
          send(type, :bar, options)
        }
      }
      assert_match '#{label_tag("foo_bar", "Bar")', ExpressTemplates.compile(&fragment)
      assert_match "#{type}_field(:foo, :bar, class: \"form-field\")", ExpressTemplates.compile(&fragment)
    end
  end

  test "textarea uses rails text_area helper" do
    fragment = -> {
      express_form(:foo) {
        textarea :bar
      }
    }
    assert_match '#{label_tag("foo_bar", "Bar")', ExpressTemplates.compile(&fragment)
    assert_match "text_area(:foo, :bar, {})", ExpressTemplates.compile(&fragment)
  end

  test "textarea passes additional html options to rails helper" do
    fragment = -> {
      express_form(:foo) {
        textarea :bar, rows: 5, class: 'tinymce form-field'
      }
    }
    assert_match '#{label_tag("foo_bar", "Bar")', ExpressTemplates.compile(&fragment)
    assert_match "text_area(:foo, :bar, rows: 5, class: \"tinymce form-field\")", ExpressTemplates.compile(&fragment)
  end

  test "hidden uses rails hidden_tag helper" do
    fragment = -> {
      express_form(:foo) {
        hidden :bar
      }
    }
    assert_no_match '#{label_tag("foo_bar", "Bar")', ExpressTemplates.compile(&fragment)
    assert_match "hidden_field(:foo, :bar, {})", ExpressTemplates.compile(&fragment)
  end

  test "hidden field passes additional html options to rails helper" do
    fragment = -> {
      express_form(:foo) {
        hidden :bar, class: 'hidden form-field', value: 'ninja'
      }
    }
    assert_no_match '#{label_tag("foo_bar", "Bar")', ExpressTemplates.compile(&fragment)
    assert_match "hidden_field(:foo, :bar, class: \"hidden form-field\", value: \"ninja\")", ExpressTemplates.compile(&fragment)
  end

end
