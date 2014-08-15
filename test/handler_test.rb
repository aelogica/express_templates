require 'test_helper'
require 'pry'
class HandlerTest < ActiveSupport::TestCase

  GARAHandler = Gara::Template::Handler.new

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
    def initialize
      @output_buffer = "original"
      @virtual_path = nil
    end

    def lookup_context
      @lookup_context ||= LookupContext.new
    end

    def link_helper
      A_LINK
    end
  end

  def new_template(body = " h1 'Hello' ", details = { format: :html })
    ActionView::Template.new(body, "hello template", details.fetch(:handler) { GARAHandler }, {:virtual_path => "hello"}.merge!(details))
  end

  def render(locals = {})
    output = @template.render(@context, locals)
    output
  end

  def with_doctype(body, alt_doctype = nil)
    "#{alt_doctype||DEFAULT_DOCTYPE}\n#{body}"
  end

  def setup
    @context = Context.new
  end


  test "our handler is registered" do
    handler = ActionView::Template.registered_template_handler("gara")
    assert_equal Gara::Template::Handler, handler
  end

  test "html generates <h1>Hello</h1> by default" do
    @template = new_template
    assert_equal "<h1>Hello</h1>", render
  end

  test "nesting elements with ruby block structure" do
    @template = new_template("ul { li 'one' ; li 'two' ; li 'three' }")
    assert_equal "<ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>", render
  end

  test "class names" do
    @template = new_template("p.whatever.another 'Lorum Ipsum' ")
    assert_equal "<p class=\"whatever another\">Lorum Ipsum</p>", render
  end

  test "other attributes" do
    @template = new_template("p('Lorum Ipsum', style: 'align: right;')")
    assert_equal "<p style=\"align: right;\">Lorum Ipsum</p>", render
  end

  test "real document has doctype and newline" do
    @template = new_template("html { body { h1 \"hello\" } }")
    assert_equal with_doctype("<html><body><h1>hello</h1></body></html>\n"), render
  end

  test "locals work" do
    @template = new_template "h1 title"
    @template.locals = [:title]
    assert_equal "<h1>Foo</h1>", render(title: 'Foo')
  end

  test "helpers returning html work without funny syntax" do
    @template = new_template("li { link_helper } ")
    without_self = render
    @template = new_template("li { self << link_helper }")
    with_self = render
    assert_equal with_self, without_self
  end

  test "helpers returning html work without funny syntax in sequence within a block" do
    @template = new_template("li { link_helper ; link_helper } ")
    without_self = render
    @template = new_template("li { self << link_helper ; self << link_helper }")
    with_self = render
    assert_equal with_self, without_self
  end


end