require 'test_helper'
require 'ostruct'

class FormForTest < ActiveSupport::TestCase
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

  def setup
    @example_compiled = -> {
    ExpressTemplates::Components::FormFor.render_in(self) {
"<form action=\"/resources/#{@resource.id}\" method=\"post\" url=\"/posts\">
  <div style=\"display:none\">
"+%Q(#{utf8_enforcer_tag})+%Q(#{method_tag(:patch)})+%Q(#{token_tag})+"
  </div>

  <div class=\"\">
"+%Q(#{label_tag("resource_name", "post title")})+%Q(#{text_field_tag("resource[name]", @resource.name, label: "post title")})+"
  </div>

  <div class=\"\">
"+%Q(#{label_tag("resource_body", "Body")})+%Q(#{text_field_tag("resource[body]", @resource.body, class: "string")})+"
  </div>

  <div class=\"field input\">
"+%Q(#{label_tag("resource_email", "Email")})+%Q(#{email_field_tag("resource[email]", @resource.email, {})})+"
  </div>

  <div class=\"\">
"+%Q(#{label_tag("resource_mobile_phone", "Mobile Phone")})+%Q(#{phone_field_tag("resource[mobile_phone]", @resource.mobile_phone, {})})+"
  </div>

  <div class=\"\">
"+%Q(#{label_tag("resource_url", "Url")})+%Q(#{url_field_tag("resource[url]", @resource.url, {})})+"
  </div>

  <div class=\"\">
"+%Q(#{label_tag("resource_number", "Number")})+%Q(#{number_field_tag("resource[number]", @resource.number, {})})+"
  </div>

  <div class=\"\">"+%Q(#{submit_tag("Save it!", {})})+"</div>
</form>
"
}
}
  end

  def example_compiled_src
    # necessary because the #source method is not perfect yet
    # ideally we would have #source_body
    @example_compiled.source_body
  end

  def simple_form(resource)
    ctx = Context.new(resource)
    fragment = -> {
      form_for(:resource, method: :put, url: '/posts') do |f|
        f.text_field :name, label: 'post title'
        f.text_field :body, class: 'string'
        f.email_field :email, wrapper_class: 'field input'
        f.phone_field :mobile_phone
        f.url_field :url
        f.number_field :number
        f.submit 'Save it!'
      end
    }
    return ctx, fragment
  end

  def select_form(resource)
    ctx = Context.new(resource)
    fragment = -> {
      form_for(:resource, method: :put) do |f|
        f.select :dropdown, ['yes', 'no'], selected: 'yes'
        f.select :dropdown, '{{ options_from_collection_for_select(@choices, "id", "name") }}'
      end
    }
    return ctx, fragment
  end

  def radio_form(resource)
    ctx = Context.new(resource)
    fragment = -> {
      form_for(:resource) do |f|
        f.radio :age, [[1, 'One'],[2, 'Two']], :first, :last
      end
    }
    return ctx, fragment
  end

  def checkbox_form(resource)
    ctx = Context.new(resource)
    fragment = -> {
      form_for(:resource, method: :put) do |f|
        f.checkbox :age, [[1, 'One'], [2, 'Two']], :first, :last
      end
    }
    return ctx, fragment
  end

  test "fields compiled source is legible and transparent" do
    ExpressTemplates::Markup::Tag.formatted do
      ctx, fragment = simple_form(resource)
      assert_equal example_compiled_src, ExpressTemplates.compile(&fragment)
    end
  end

  test "select compiled source is legible and transparent" do
    @example_compiled = -> {
    ExpressTemplates::Components::FormFor.render_in(self) {
"<form action=\"/resources/#{@resource.id}\" method=\"post\">
  <div style=\"display:none\">
"+%Q(#{utf8_enforcer_tag})+%Q(#{method_tag(:patch)})+%Q(#{token_tag})+"
  </div>

  <div class=\"\">
"+%Q(#{label_tag("resource_dropdown", "Dropdown")})+%Q(#{select_tag("resource[dropdown]", '<option selected=selected>yes</option><option >no</option>'.html_safe, {})})+"
  </div>

  <div class=\"\">
"+%Q(#{label_tag("resource_dropdown", "Dropdown")})+%Q(#{select_tag("resource[dropdown]",  options_from_collection_for_select(@choices, "id", "name") , {})})+"
  </div>
</form>
"
}
}
    ExpressTemplates::Markup::Tag.formatted do
      ctx, fragment = select_form(resource)
      assert_equal example_compiled_src, ExpressTemplates.compile(&fragment)
    end
  end

  test "radio compiled source is legible and transparent" do
    @example_compiled = -> {
      ExpressTemplates::Components::FormFor.render_in(self) {
"<form action=\"/resources\" method=\"post\">
  <div style=\"display:none\">
"+%Q(#{utf8_enforcer_tag})+%Q(#{method_tag(:post)})+%Q(#{token_tag})+"
  </div>

  <div class=\"\">
"+%Q(#{collection_radio_buttons(:resource, :age, [[1, "One"], [2, "Two"]], :first, :last, {}) do |b|
                  b.label(class: 'radio') { b.radio_button + b.text }
                end})+"
  </div>
</form>
"
}
}

    ExpressTemplates::Markup::Tag.formatted do
      ctx, fragment = radio_form(resource)
      assert_equal example_compiled_src, ExpressTemplates.compile(&fragment)
    end
  end

  test "checkbox compiled source is legible and transparent" do
    @example_compiled = -> {
      ExpressTemplates::Components::FormFor.render_in(self) {
"<form action=\"/resources/#{@resource.id}\" method=\"post\">
  <div style=\"display:none\">
"+%Q(#{utf8_enforcer_tag})+%Q(#{method_tag(:patch)})+%Q(#{token_tag})+"
  </div>

  <div class=\"\">
"+%Q(#{collection_check_boxes(:resource, :age, [[1, "One"], [2, "Two"]], :first, :last, {}) do |b|
                  b.label(class: 'checkbox') { b.check_box + b.text }
                end})+"
  </div>
</form>
"
}
}

    ExpressTemplates::Markup::Tag.formatted do
      ctx, fragment = checkbox_form(resource)
      assert_equal example_compiled_src, ExpressTemplates.compile(&fragment)
    end

  end
end
