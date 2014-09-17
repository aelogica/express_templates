module Gara
  module Renderer
    # render accepts source or block, expands to macros
    # compiles the resulting macros 
    # and then evaluates the resulting string of ruby in the context provided
    def render context=nil, template_source=nil, &block
      expander = Gara::Expander.new(nil)
      expanded_template = if block
        (expander.expand(&block).map(&:compile).join(';'))
      else
        expander.expand(template_source).map(&:compile).join(";")
      end
      context.instance_eval expanded_template
    end
  end
end