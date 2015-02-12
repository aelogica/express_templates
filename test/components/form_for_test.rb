require 'test_helper'
require 'ostruct'

class FormForTest < ActiveSupport::TestCase
  class Context
    def initialize(post)
      @post = post
    end
  end

  def post
    OpenStruct.new(id: 1, name: 'Foo', body: 'Hello world', email: 'some@email.com', phone: '123123123')
  end

  EXAMPLE_MARKUP = <<-HTML
<form id="edit_post_1" action="/posts/1" accept-charset="UTF-8" method="post">

  <div class="input string">
    <label class="string" for="post_name">Post Title</label>

    <input class="string" type="text" value="Foo" name="post[name]" id="post_name">
  </div>

  <div class="input string">
    <label class="string" for="post_body"> Body</label>
    <input class="string" type="text" value="hot" name="post[body]" id="post_body">
  </div>
  <input type="submit" name="commit" value="Update Post" class="btn">
</form>
  HTML

  EXAMPLE_COMPILED = -> {
    ExpressTemplates::Components::FormFor.render_in(self) {
"<form action=\"/posts\">
  <div class='input string'>
    #{label_tag(:name, 'Post Title', class: 'string')}#{text_field_tag(:name, @post.name, class: 'string')}
  </div>
  <div class='input string'>
    #{label_tag(:body, nil, class: 'string')}#{text_field_tag(:body, @post.body, class: 'string')}
  </div>
  <div class='input string'>
    #{label_tag(:email, nil, class: 'string')}#{email_field_tag(:body, @post.email, class: 'string')}
  </div>
  <div class='input string'>
    #{label_tag(:phone, nil, class: 'string')}#{phone_field_tag(:body, @post.phone, class: 'string')}
  </div>
</form>"
}
}

  def example_compiled_src
    # necessary because the #source method is not perfect yet
    # ideally we would have #source_body
    EXAMPLE_COMPILED.source_body
  end

  def simple_form(post)
    ctx = Context.new(post)
    fragment = -> {
      form_for(:post) do |f|
        f.text_field :name, label: 'Post Title'
        f.text_field :body
        f.email_field :email
        f.phone_field :phone
      end
    }
    return ctx, fragment
  end

  # test "example view code evaluates to example markup" do
  #   assert_equal EXAMPLE_MARKUP, Context.new(post).instance_eval(EXAMPLE_COMPILED.source_body)
  # end

  test "compiled source is legible and transparent" do
    ExpressTemplates::Markup::Tag.formatted do
      ctx, fragment = simple_form(post)
      puts "=" * 100
      puts example_compiled_src
      puts "=" * 100
      puts ExpressTemplates.compile(&fragment)
      puts "=" * 100
      assert_equal example_compiled_src, ExpressTemplates.compile(&fragment)
    end
  end

end
