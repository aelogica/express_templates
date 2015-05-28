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
      assert_match "#{type}_field(:foo, :bar)", ExpressTemplates.compile(&fragment)
    end
  end

  test "textarea uses rails text_area helper" do
    fragment = -> {
      express_form(:foo) {
        textarea :bar
      }
    }
    assert_match '#{label_tag("foo_bar", "Bar")', ExpressTemplates.compile(&fragment)
    assert_match "text_area(:foo, :bar)", ExpressTemplates.compile(&fragment)
  end


  test "hidden uses rails hidden_tag helper" do
    fragment = -> {
      express_form(:foo) {
        hidden :bar
      }
    }
    assert_no_match '#{label_tag("foo_bar", "Bar")', ExpressTemplates.compile(&fragment)
    assert_match "hidden_field(:foo, :bar)", ExpressTemplates.compile(&fragment)
  end

end
