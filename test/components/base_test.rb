require 'test_helper'

class BaseTest < ActiveSupport::TestCase

  class UnorderedList < ExpressTemplates::Components::Base
    tag :ul

    has_attributes :class       => 'something',
                   'data-foo'   => 'something-else'

    contains {
      li { "Some stuff" }
    }
  end

  test ".tag_name determines the enclosing tag" do
    assert_match /^\<ul/, render { unordered_list }
  end

  test ".has_attributes creates default attributes" do
    assert_match /class="[^"]*something[^"]*"/, render { unordered_list }
    assert_match /data-foo="[^"]*something-else[^"]*"/, render { unordered_list }
  end

  test ".contains places fragment inside the enclosing tag" do
    markup = render { unordered_list }
    assert_match /\<ul.*\<li.*\/li\>.*\/ul\>/, markup.gsub("\n", '')
  end

  test "class name is dasherized instead of underscored" do
    assert_match /class="[^"]*unordered-list[^"]*"/, render { unordered_list }
  end

  test "options are passed to html attributes" do
    assert_match /rows="5"/, render { unordered_list(rows: 5) }
  end

  test "class option adds a class, does not override" do
    markup = render { unordered_list(class: 'extra') }
    assert_match /class="[^"]*something[^"]*"/, markup
    assert_match /class="[^"]*unordered-list[^"]*"/, markup
    assert_match /class="[^"]*extra[^"]*"/, markup
  end

end