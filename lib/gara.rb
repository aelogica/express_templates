module Gara
  require 'gara/delegate_helper'
  extend DelegateHelper

  require 'gara/template/handler'
  require 'gara/delegator'
  require 'gara/html5_emitter'
  ActionView::Template.register_template_handler :gara, Gara::Template::Handler
end
