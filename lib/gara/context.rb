module Gara
  class Context

    include Gara::Html5Emitter

    def initialize(view_renderer, view_assigns, controller)
      @delegate = controller.view_context_class.new(view_renderer, view_assigns, controller)
      view_assigns.each_pair do |key, value|
        instance_variable_set("@#{key}".to_sym, value)
      end

      @view_flow  = @delegate.view_flow
      @delegate.output_buffer = ActionView::OutputBuffer.new
    end

    def view_flow ; @delegate.view_flow ; end
    def output_buffer ; @delegate.output_buffer ; end

    def _layout_for(name=nil)
      @delegate._layout_for(name)
    end

    def capture(&block)
      @delegate.capture(&block)
    end

    def method_missing(*args)
      # We want to detect when a helper is called from
      # within a template, and wrap it so its result is
      # concat'd  but not to do it to any helpers that are
      # called from within that helper.
      begin
        already_wrapped = Thread.current[:wrap_context]
        Thread.current[:wrap_context] = true unless [:capture, :concat].include?(args.first)
        if already_wrapped # Avoid concating interim results on the stack
          @delegate.send(*args)
        else
          @delegate.concat @delegate.send(*args)
        end
      ensure
        Thread.current[:wrap_context] = false
      end
    end

  end
end