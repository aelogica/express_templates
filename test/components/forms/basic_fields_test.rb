require 'test_helper'

class BasicFieldsTest < ActiveSupport::TestCase

  BASIC_FIELDS = %w(email phone text password color date datetime
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
    options = {class: 'form-field'}
    BASIC_FIELDS.each do |type|
      html = arbre {
        express_form(:foo) {
          send(type, :bar, options)
        }
      }
      assert_match label_html, html
      assert_match /input.*type="#{field_type_map[type]}"/, html
      assert_match /input.*class="form-field"/, html
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

end
