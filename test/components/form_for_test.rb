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
"<form action=\"/resources\">
  <div class=\"input\">
    #{label_tag(:name, 'Post Title')}#{text_field_tag(:name, @resource.name)}
  </div>
  <div class=\"input\">
    #{label_tag(:body, nil, class: 'string')}#{text_field_tag(:body, @resource.body, class: 'string')}
  </div>
  <div class=\"input\">
    #{label_tag(:email, nil)}#{email_field_tag(:email, @resource.email)}
  </div>
  <div class=\"input\">
    #{label_tag(:phone, nil)}#{phone_field_tag(:phone, @resource.phone)}
  </div>
  <div class=\"input\">
    #{label_tag(:url, nil)}#{url_field_tag(:url, @resource.url)}
  </div>
  <div class=\"input\">
    #{label_tag(:number, nil)}#{number_field_tag(:number, @resource.number)}
  </div>
  <div class=\"select\">
    #{label_tag(:dropdown, nil)}#{select_tag(:dropdown, "<option selected=selected>yes</option><option>no</option>".html_safe)}
  </div>
</form>"
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
      form_for(:resource) do |f|
        f.text_field :name, label: 'post title'
        f.text_field :body, class: 'string'
        f.email_field :email
        f.phone_field :phone
        f.url_field :url
        f.number_field :number
      end
    }
    return ctx, fragment
  end

  def select_form(resource)
    ctx = Context.new(resource)
    fragment = -> {
      form_for(:resource) do |f|
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
        f.radio_button :gender, 'male'
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
"<form action=\"/resources\">
  <div class=\"select\">
    #{label_tag(:dropdown, nil)}#{select_tag(:dropdown, "<option selected=selected>yes</option><option>no</option>".html_safe)}
  </div>
  <div class=\"select\">
    #{label_tag(:dropdown, nil)}#{select_tag(:dropdown, options_from_collection_for_select(@choices, "id", "name"))}
  </div>
</form>"
}
}
    ExpressTemplates::Markup::Tag.formatted do
      ctx, fragment = select_form(resource)
      assert_equal example_compiled_src, ExpressTemplates.compile(&fragment)
    end
  end

  test "radiobutton compiled source is legible and transparent" do
    @example_compiled = -> {
      ExpressTemplates::Components::FormFor.render_in(self) {
"<form action=\"/resources\">
  <div class=\"/radio_button\">
    #{label_tag(:gender, nil)}#{radio_button_tag(:gender, 'male')}
  </div>
</form>"
}
}

    ExpressTemplates::Markup::Tag.formatted do
      ctx, fragment = radio_form(resource)
      puts "=" * 100
      puts example_compiled_src
      puts "=" * 100
      puts ExpressTemplates.compile(&fragment)
      puts "=" * 100
      assert_equal example_compiled_src, ExpressTemplates.compile(&fragment)
    end
  end
end
