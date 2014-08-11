module Gara

  require 'gara/template/handler'
  require 'gara/context_delegate'
  ActionView::Template.register_template_handler :gara, Gara::Template::Handler
end
