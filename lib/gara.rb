module Gara
  require 'gara/template/handler'
  require 'gara/html5_emitter'
  require 'gara/renderer'
  require 'gara/expander'
  require 'gara/components'
  require 'gara/context'
  extend Renderer
  if defined?(Rails)
    ::ActionView::Template.register_template_handler :gara, Gara::Template::Handler
    ActionController::Base.class_eval do
      def view_context
        Gara::Context.new(view_renderer, view_assigns, self)
      end
    end
  end

end
