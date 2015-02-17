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
"<form action=\"/resources\" method=\"put\" url=\"/yolo\">
  <div style=\"display:none\">
"+%Q(#{utf8_enforcer_tag})+%Q(#{method_tag(:post)})+%Q(#{token_tag})+"
  </div>
"+%Q(#{label_tag(:name, "post title")})+%Q(#{text_field_tag(:name, @resource.name, label: "post title")})+%Q(#{label_tag(:body, nil)})+%Q(#{text_field_tag(:body, @resource.body, class: "string")})+%Q(#{label_tag(:email, nil)})+%Q(#{email_field_tag(:email, @resource.email, {})})+%Q(#{label_tag(:phone, nil)})+%Q(#{phone_field_tag(:phone, @resource.phone, {})})+%Q(#{label_tag(:url, nil)})+%Q(#{url_field_tag(:url, @resource.url, {})})+%Q(#{label_tag(:number, nil)})+%Q(#{number_field_tag(:number, @resource.number, {})})+%Q(#{submit_tag("Save it!", {})})+"
</form>
"
}
}
  end

  EXAMPLE_MARKUP = <<-HTML
<form id="edit_resource_1" action="/resources/1" accept-charset="UTF-8" method="post">

  <div class="input string">
    <label class="string" for="resource_name">Post Title</label>

    <input class="string" type="text" value="Foo" name="resource[name]" id="resource_name">
  </div>

  <div class="input string">
    <label class="string" for="resource_body"> Body</label>
    <input class="string" type="text" value="hot" name="resource[body]" id="resource_body">
  </div>
  <input type="submit" name="commit" value="Update Resource" class="btn">
</form>
  HTML

  def example_compiled_src
    # necessary because the #source method is not perfect yet
    # ideally we would have #source_body
    @example_compiled.source_body
  end

  def simple_form(resource)
    ctx = Context.new(resource)
    fragment = -> {
      form_for(:resource, method: :put, url: '/yolo') do |f|
        f.text_field :name, label: 'post title'
        f.text_field :body, class: 'string'
        f.email_field :email
        f.phone_field :phone
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
      form_for(:resource) do |f|
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
"<form action=\"/resources\" method=\"put\">
  <div style=\"display:none\">
"+%Q(#{utf8_enforcer_tag})+%Q(#{method_tag(:post)})+%Q(#{token_tag})+"
  </div>
"+%Q(#{label_tag(:dropdown, nil)})+%Q(#{select_tag(:dropdown, '<option selected=selected>yes</option><option >no</option>'.html_safe, {})})+%Q(#{label_tag(:dropdown, nil)})+%Q(#{select_tag(:dropdown,  options_from_collection_for_select(@choices, "id", "name") , {})})+"
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
"<form action=\"/resources\">
  <div style=\"display:none\">
"+%Q(#{utf8_enforcer_tag})+%Q(#{method_tag(:post)})+%Q(#{token_tag})+"
  </div>
"+%Q(#{collection_radio_buttons(:resource, :age, [[1, "One"], [2, "Two"]], :first, :last, {}) do |b|
                b.label(class: 'radio') { b.radio_button + b.text }
              end})+"
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
"<form action=\"/resources\">
  <div style=\"display:none\">
"+%Q(#{utf8_enforcer_tag})+%Q(#{method_tag(:post)})+%Q(#{token_tag})+"
  </div>
"+%Q(#{collection_check_boxes(:resource, :age, [[1, "One"], [2, "Two"]], :first, :last, {}) do |b|
                b.label(class: 'checkbox') { b.check_box + b.text }
              end})+"
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
