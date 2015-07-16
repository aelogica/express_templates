module ExpressTemplates
  require 'arbre'
  require 'arbre/patches'
  require 'core_extensions/proc'
  require 'core_extensions/string'
  require 'express_templates/indenter'
  require 'express_templates/components'
  require 'express_templates/template/handler'
  require 'express_templates/renderer'
  require 'express_templates/compiler'
  require 'express_templates/interpolator'
  extend Renderer
  extend Compiler
  if defined?(Rails)
    ::ActionView::Template.register_template_handler :et, ExpressTemplates::Template::Handler
  end

end
