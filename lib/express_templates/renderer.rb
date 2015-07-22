module ExpressTemplates
  module Renderer
    # render accepts source or block, evaluates the resulting string of ruby in the context provided
    def render context=nil, template_or_src=nil, &block
      compiled_template = compile(template_or_src, &block)
      context.instance_eval compiled_template
    end
  end
end