module ExpressTemplates
  require 'core_extensions/proc'
  require 'express_templates/indenter'
  require 'express_templates/macro'
  require 'express_templates/markup'
  require 'express_templates/components'
  require 'express_templates/template/handler'
  require 'express_templates/renderer'
  require 'express_templates/expander'
  require 'express_templates/compiler'
  extend Renderer
  extend Compiler
  if defined?(Rails)
    ::ActionView::Template.register_template_handler :et, ExpressTemplates::Template::Handler
  end

end
