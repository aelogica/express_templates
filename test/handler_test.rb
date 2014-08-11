require 'test_helper'
require 'pry'
class HandlerTest < ActiveSupport::TestCase

  GARAHandler = Gara::Template::Handler.new

  DEFAULT_DOCTYPE = "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\" \"http://www.w3.org/TR/REC-html40/loose.dtd\">"

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
    assert_equal with_doctype("<h1>Hello</h1>\n"), render
  end
end