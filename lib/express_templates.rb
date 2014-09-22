module ExpressTemplates
  require 'express_templates/template/handler'
  require 'express_templates/html5_emitter'
  require 'express_templates/renderer'
  require 'express_templates/expander'
  require 'express_templates/components'
  extend Renderer
  if defined?(Rails)
    ::ActionView::Template.register_template_handler :et, ExpressTemplates::Template::Handler
  end

end
