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

  def express_form
    "ExpressTemplates::Components::Forms::ExpressForm".constantize
  end

  test "express_form component exists" do
    assert express_form
  end

  def compile_simplest_form
    ctx, fragment = simplest_form(resource)
    ExpressTemplates.compile(&fragment)
  end

  test "simplest form renders" do
    assert compile_simplest_form
  end

  test "simplest form contains form tag" do
    assert_match "<form", compile_simplest_form
  end

  test "simplest form contains rails form helpers" do
    compiled_src = compile_simplest_form
    assert_match "utf8_enforcer_tag", compiled_src
    assert_match "method_tag(", compiled_src
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

  test "#form_action uses url helpers" do
    assert_equal "{{@foo.try(:persisted?) ? foo_path(@foo.id) : foos_path}}", express_form.new(:foo).form_action
  end

  test "#form_action uses correct path helper for update/patch" do
    assert_equal "{{@foo.try(:persisted?) ? foo_path(@foo.id) : foos_path}}", express_form.new(:foo, method: :put).form_action
  end

  test "simplest_form uses form_action for the action" do
    form_open_tag = compile_simplest_form.match(/<form[^>]*>/)[0]
    assert_match 'action=\"#{@resource.try(:persisted?) ? resource_path(@resource.id) : resources_path}\"', form_open_tag
  end

  test "express_form default method is POST" do
    form_open_tag = compile_simplest_form.match(/<form[^>]*>/)[0]
    assert_match 'method=\"POST\"', form_open_tag
  end

  test "express_form accepts :resource_name for removing namespace" do
    fragment = -> {
      express_form(:admin_foo, resource_name: 'foo') {
        submit "Save!"
      }
    }
    expanded_nodes = ExpressTemplates::Expander.new(nil).expand(fragment.source_body)
    assert_equal 'foo', expanded_nodes.first.resource_name
  end

  test "express_form has a namespace option with nil default" do
    form = ExpressTemplates::Components::Forms::ExpressForm
    assert_nil form.new(:person).namespace
    assert_equal 'express_engine', form.new(:person, namespace: 'express_engine').namespace
  end

end
