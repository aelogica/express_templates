module ExpressTemplates
  require 'express_templates/markup'
  require 'express_templates/components'
  require 'express_templates/template/handler'
  require 'express_templates/renderer'
  require 'express_templates/expander'
  extend Renderer
  if defined?(Rails)
    ::ActionView::Template.register_template_handler :et, ExpressTemplates::Template::Handler
  end

end
