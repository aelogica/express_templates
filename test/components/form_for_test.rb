require 'test_helper'
require 'ostruct'

class FormForTest < ActiveSupport::TestCase
  class Context
    def initialize(post)
      @post = post
    end
  end

  def post
    OpenStruct.new(id: 1, name: 'Foo', body: 'Hello world')
  end

  EXAMPLE_MARKUP = <<-HTML
<form id="edit_post_1" action="/posts/1" accept-charset="UTF-8" method="post">

  <div class="input string">
    <label class="string" for="post_name">Name</label>

    <input class="string" type="text" value="Foo" name="post[name]" id="post_name">
  </div>

  <div class="input string optional post_body">
    <label class="string optional" for="post_body"> Body</label>
    <input class="string optional" type="text" value="hot" name="post[body]" id="post_body">
  </div>
  <input type="submit" name="commit" value="Update Post" class="btn">
</form>
  HTML

  EXAMPLE_COMPILED = -> {
    ExpressTemplates::Components::FormFor.render_in(self) {
      "<form id='edit_post_1' action='/posts/1' accept-charset='UTF-8' method='post'>

<div class='input string'>
  <label for='post_name'>Name</label>
  <input type='text'>Name</input>
</div>

<div class='input string'>
  <label for='post_body'>Body</label>
  <input type='text'>Body</input>
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
      # form_for(:post) do |f|
      #   f.text_field :name
      #   f.text_field :body
      # end
      form_for(:post) do |f|
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
      assert_equal example_compiled_src, ExpressTemplates.compile(&fragment)
    end
  end

end
