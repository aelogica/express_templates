require 'test_helper'
require 'ostruct'

class ExpressFormTest < ActiveSupport::TestCase
  class Context
    def initialize(resource)
      @resource = resource
    end
  end

  def resource
    OpenStruct.new(
      id: 1,
      name: 'Foo',
      body: 'Hello world',
      email: 'some@email.com',
      phone: '123123123',
      url: 'http://someurl.com',
      number: 123,
      dropdown: 'yes',
      gender: 'Male'
    )
  end

  def simplest_form(resource)
    ctx = Context.new(resource)
    fragment = -> {
      express_form(:resource) {
        submit value: 'Save it!'
      }
    }
    return ctx, fragment
  end

  test "express_form component exists" do
    assert ExpressTemplates::Components::Forms::ExpressForm
  end

  def compile_simplest_form
    ctx, fragment = simplest_form(resource)
    ExpressTemplates.compile(&fragment)
  end

  test "simplest form renders" do
    assert_not_nil compile_simplest_form
  end

  test "simplest form contains form tag" do
    assert_match "<form", compile_simplest_form
  end

  test "simplest form contains rails form helpers" do
    compiled_src = compile_simplest_form
    assert_match "utf8_enforcer_tag", compiled_src
    assert_match "method_tag(:post)", compiled_src
    assert_match "token_tag", compiled_src
  end

  test "simplest_form contains submit" do
    assert_match 'submit_tag', compile_simplest_form
  end

  test "simplest_form adopts children (submit has reference to parent)" do
    ctx, fragment = simplest_form(resource)
    expanded_nodes = ExpressTemplates::Expander.new(nil).expand(fragment.source_body)
    assert_instance_of ExpressTemplates::Components::Forms::ExpressForm,
                       expanded_nodes.first.children.last.parent
  end

  test "simplest form compiled source is legible " do
    @example_compiled = -> {
"<form action=\"/resources/#{@resource.id}\" method=\"post\">
  <div style=\"display:none\">
"+%Q(#{utf8_enforcer_tag})+%Q(#{method_tag(:post)})+%Q(#{token_tag})+"
  </div>
  <div class=\"form-group widget-buttons\">
"+%Q(#{submit_tag("Save it!", class: "submit primary")})+"</div>
</form>
"
    }
  end

end