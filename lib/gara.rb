module Gara
  require 'gara/template/handler'
  require 'gara/html5_emitter'
  require 'gara/renderer'
  require 'gara/expander'
  require 'gara/components'
  extend Renderer
  if defined?(Rails)
    ::ActionView::Template.register_template_handler :gara, Gara::Template::Handler
  end

end
