require 'test_helper'
require 'active_model'

class BasicFieldsTest < ActiveSupport::TestCase

  BASIC_FIELDS = %w(email phone text password color file date datetime
                    datetime_local number range
                    search telephone time url week)

  def assigns
    {resource: resource}
  end

  def field_type_map
    Hash[BASIC_FIELDS.map {|f| [f, f]}].merge(
      {'phone'          => 'tel',
       'telephone'          => 'tel',
       'datetime_local' => 'datetime-local' })
  end

  def label_html
    '<label for="foo_bar">Bar</label>'
  end

  test "all fields work" do
    BASIC_FIELDS.each do |type|
      fragment = -> (ctx) {
        express_form(:foo) {
          send(type, :bar)
        }
      }
      html = arbre(&fragment)
      assert_match label_html, html
      assert_match(/input.*type="#{field_type_map[type]}"/, html)
      # assert_match "#{type}_field(:foo, :bar, {})", arbre(&fragment)
    end
  end

  test "passing html options to fields work" do
    options = {style: 'width: 10em;'}
    ['email'].each do |type|
      html = arbre {
        express_form(:foo) {
          send(type, :bar, options)
        }
      }
      assert_match label_html, html
      assert_match /input.*type="#{field_type_map[type]}"/, html
      assert_match /input.*style="width: 10em;"/, html
    end
  end

  test "textarea uses rails text_area helper" do
    html = arbre {
      express_form(:foo) {
        textarea :bar
      }
    }
    assert_match label_html, html
    assert_match /<textarea name="foo\[bar\]" id="foo_bar"><\/textarea>/, html.gsub("\n", '')
  end

  test "textarea passes additional html options to rails helper" do
    html = arbre {
      express_form(:foo) {
        textarea :bar, rows: 5, class: 'tinymce form-field'
      }
    }
    assert_match label_html, html
    assert_match /<textarea rows="5" class="tinymce form-field" name="foo\[bar\]" id="foo_bar"><\/textarea>/, html.gsub("\n", '') 
  end

  test "hidden uses rails hidden_tag helper" do
    html = arbre {
      express_form(:foo) {
        hidden :bar
      }
    }
    assert_no_match label_html, html
    assert_match '<input type="hidden"', html
  end

  test "hidden field passes additional html options to rails helper" do
    html = arbre {
      express_form(:foo) {
        hidden :bar, class: 'hidden form-field', value: 'ninja'
      }
    }
    assert_no_match label_html, html
    assert_match /<input class="hidden form-field" value="ninja" type="hidden" name="foo\[bar\]" id="foo_bar"/, html
  end

  def resource_with_errors
    mock_resource = resource
    class << mock_resource
      def errors
        errors = ActiveModel::Errors.new(self)
        errors.add(:name, "Can't be Foo")
        errors
      end
    end
    mock_resource
  end

  def has_error_class
    /div[^>]*class="[^"]*error[^"]*"/
  end

  def has_error_class_on(field, html)
    md = html.match(/(<div[^>]*id="[^"]*#{field}_wrapper[^"]*"[^>]*>)/)
    assert md, "field has no wrapper"
    return !!md[1].match(has_error_class)
  end

  test "adds error class if there are errors on a field with no input attributes" do
    html_with_error = arbre(resource: resource_with_errors) {
      express_form(:foo) {
       text :name
       text :body
      }
    }
    assert resource_with_errors.errors.any?
    assert assigns[:resource].errors.any?
    assert has_error_class_on(:name, html_with_error), "name field has no error when expected"
    refute has_error_class_on(:body, html_with_error), "body field has error class when it should not"
  end

    test "adds error class if there are errors on a field with no class set" do
    html_with_error = arbre(resource: resource_with_errors) {
      express_form(:foo) {
       text :name, value: 'ninja'
      }
    }
    assert resource_with_errors.errors.any?
    assert assigns[:resource].errors.any?
    assert_match has_error_class, html_with_error
  end

    test "adds error to class if there are errors on a field with existing class" do
    html_with_error = arbre(resource: resource_with_errors) {
      express_form(:foo) {
       text :name, value: 'ninja', class: 'slug'
      }
    }
    assert resource_with_errors.errors.any?
    assert assigns[:resource].errors.any?
    assert_match has_error_class, html_with_error
  end

end
