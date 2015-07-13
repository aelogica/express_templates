require 'test_helper'

class HandlerTest < ActiveSupport::TestCase

  DEFAULT_DOCTYPE = "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\" \"http://www.w3.org/TR/REC-html40/loose.dtd\">"
  A_LINK = %Q(<a href="#">link</a>)

  class LookupContext
    def disable_cache
      yield
    end

    def find_template(*args)
    end

    attr_accessor :formats
  end

  class Context
    include ActionView::Context
    include ActionView::Helpers::TagHelper
    def initialize(*args)
      @output_buffer = "original"
      @virtual_path = nil
    end

    def lookup_context
      @lookup_context ||= LookupContext.new
    end

    def concat(string)
      @output_buffer << string
    end

    def capture(&block)
      block.call
    end

    def assigns
      {}
    end

    def link_helper
      A_LINK.html_safe
    end
  end

  def new_template(body = " h1 'Hello' ", details = { format: :html })
    ActionView::Template.new(body, "hello template", details.fetch(:handler) { ExpressTemplates::Template::Handler.new }, {:virtual_path => "hello"}.merge!(details))
  end

  def render(locals = {})
    output = @template.render(@context, locals)
    output
  end

  def with_doctype(body, alt_doctype = nil)
    "#{alt_doctype||DEFAULT_DOCTYPE}\n#{body}"
  end

  def setup
    controller = Object.new
    class << controller
      def view_context_class ; Context ; end
    end
    @context = Context.new(nil, {}, controller)
  end


  test "our handler is registered" do
    handler = ActionView::Template.registered_template_handler("et")
    assert_equal ExpressTemplates::Template::Handler, handler
  end

  test "html generates <h1>Hello</h1> by default" do
    @template = new_template
    result = render
    assert_equal "<h1>Hello</h1>\n", result
  end

  test "nesting elements with ruby block structure" do
    @template = new_template("ul { li 'one' ; li 'two' ; li 'three' }")
    assert_equal "<ul>\n  <li>one</li>\n  <li>two</li>\n  <li>three</li>\n</ul>\n", render
  end

  # TODO?: Does not work with arbre
  # test "class names" do
  #   @template = new_template("p.whatever.another 'Lorum Ipsum' ")
  #   assert_equal "<p class=\"whatever another\">Lorum Ipsum</p>\n", render
  # end

  test "string in block works" do
    @template = new_template "h1 { 'foo' } "
    assert_equal "<h1>foo</h1>\n", render
  end

  # test "real document has doctype and newline" do
  #   @template = new_template("html { body { h1 \"hello\" } }")
  #   assert_equal with_doctype("<html xmlns=\"http://www.w3.org/1999/xhtml\">\n  <body>\n    <h1>hello</h1>\n  </body>\n</html>\n"), render
  # end


  test "other attributes" do
    @template = new_template("para('Lorum Ipsum', style: 'align: right;')")
    assert_equal "<p style=\"align: right;\">Lorum Ipsum</p>\n", render
  end

  test "locals work" do
    @template = new_template "h1 { my_title }"
    @template.locals = [:my_title]
    assert_equal "<h1>Foo</h1>\n", render(my_title: 'Foo')
  end

  test "helpers returning html when alone in a block" do
    @template = new_template("li { link_helper } ")
    assert_equal "<li>#{A_LINK}</li>\n", render
  end

  test "helpers returning html work in sequence within a block" do
    @template = new_template("li { link_helper ; link_helper } ")
    assert_equal "<li>\n#{A_LINK}#{A_LINK}</li>\n", render
  end

end