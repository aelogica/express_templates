require 'test_helper'

class ContentForTest < ActiveSupport::TestCase

  class Context
    def content_for(label, markup=nil, &block)
      @blocks ||= {}
      if block || markup
        @blocks[label] = block ? block.call : markup
        nil
      else
        @blocks[label]
      end
    end
  end

  test "content_for accepts a block of express template" do
    fragment = -> {
      content_for(:whatever) { h1 'hello' }
    }
    context = Context.new
    markup = ExpressTemplates.render(context, &fragment)
    assert_equal %Q(<h1>hello</h1>), context.content_for(:whatever)
  end

  test "content_for accepts a second argument which contains markup" do
    fragment = -> {
      content_for :title, "Foo"
    }
    context = Context.new
    markup = ExpressTemplates.render(context, &fragment)
    assert_equal 'Foo', context.content_for(:title)
  end

  test "content_for without a body returns the markup" do
    fragment = -> {
      content_for :title
    }
    context = Context.new
    context.content_for :title, "Foo"
    markup = ExpressTemplates.render(context, &fragment)
    assert_equal 'Foo', markup
  end

  test "content_for body is html_safe" do
    arg_frag = -> {
      content_for :title, "<h1>Foo</h1>"
    }
    context = Context.new
    markup = ExpressTemplates.render(context, &arg_frag)
    assert context.content_for(:title).html_safe?

    block_frag = -> {
      content_for(:title) { h1 "Foo" }
    }
    markup = ExpressTemplates.render(context, &block_frag)
    assert context.content_for(:title).html_safe?
  end

end