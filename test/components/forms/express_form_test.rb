require 'test_helper'

  class Foo
    def self.columns ; [] ; end
  end

class ExpressFormTest < ActiveSupport::TestCase

  def assigns
    {resource: resource}
  end

  def simplest_form
    arbre {
      express_form(:resource) {
        submit value: 'Save it!'
      }
    }
  end

  test "simplest form renders" do
    assert simplest_form
  end

  test "simplest form will have the proper id" do
    assert_match /<form.*id="resource_1"/, simplest_form
  end

  test "simplest form contains form tag" do
    assert_match "<form", simplest_form
  end

  test "express_form contents are inside the form" do
    assert_match /<form.*submit.*\/form>/, simplest_form.gsub("\n",'')
  end

  test "simplest form contains rails form helpers" do
    compiled_src = simplest_form
    assert_match "input name=\"utf8\" type=\"hidden\"", compiled_src
    assert_match "input type=\"hidden\" name=\"_method\"", compiled_src
    assert_match "name=\"authenticity_token\" value=\"AUTH_TOKEN\"", compiled_src
    assert_match /<form.*authenticity_token.*\/form>/, compiled_src.gsub("\n",'')
  end

  test "simplest_form contains submit" do
    assert_match '<input type="submit" name="commit" value="Save it!" />', simplest_form
  end

  test "simplest_form uses form_action for the action" do
    form_open_tag = simplest_form.match(/<form[^>]*>/)[0]
    assert_match 'action="/resources"', form_open_tag
  end

  test "express_form default method is POST" do
    assert_match 'method="POST"', simplest_form
  end

end
