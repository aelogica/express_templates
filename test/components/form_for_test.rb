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
      dropdown: 'yes'
    )
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

  EXAMPLE_COMPILED = -> {
    ExpressTemplates::Components::FormFor.render_in(self) {
"<form action=\"/resources\">
  <div class='input'>
    #{label_tag(:name, 'Post Title', class: 'string')}#{text_field_tag(:name, @resource.name)}
  </div>
  <div class='input'>
    #{label_tag(:body, nil, class: 'string')}#{text_field_tag(:body, @resource.body)}
  </div>
  <div class='input'>
    #{label_tag(:email, nil, class: 'string')}#{email_field_tag(:email, @resource.email)}
  </div>
  <div class='input'>
    #{label_tag(:phone, nil, class: 'string')}#{phone_field_tag(:phone, @resource.phone)}
  </div>
  <div class='input'>
    #{label_tag(:url, nil, class: 'string')}#{url_field_tag(:url, @resource.url)}
  </div>
  <div class='input'>
    #{label_tag(:number, nil, class: 'string')}#{number_field_tag(:number, @resource.number)}
  </div>
  <div class='select'>
      #{select_tag(:dropdown)}
  </div>
</form>"
}
}

  def example_compiled_src
    # necessary because the #source method is not perfect yet
    # ideally we would have #source_body
    EXAMPLE_COMPILED.source_body
  end

  def simple_form(resource)
    ctx = Context.new(resource)
    fragment = -> {
      form_for(:resource) do |f|
        f.text_field :name, label: 'Post Title'
        f.text_field :body
        f.email_field :email
        f.phone_field :phone
        f.url_field :url
        f.number_field :number
        f.select :dropdown, resource.dropdown
      end
    }
    return ctx, fragment
  end

  # test "example view code evaluates to example markup" do
  #   assert_equal EXAMPLE_MARKUP, Context.new(resource).instance_eval(EXAMPLE_COMPILED.source_body)
  # end

  test "compiled source is legible and transparent" do
    ExpressTemplates::Markup::Tag.formatted do
      ctx, fragment = simple_form(resource)
      puts "=" * 100
      puts example_compiled_src
      puts "=" * 100
      puts ExpressTemplates.compile(&fragment)
      puts "=" * 100
      assert_equal example_compiled_src, ExpressTemplates.compile(&fragment)
    end
  end
end
