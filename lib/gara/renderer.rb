module Gara
  module Renderer
    def render context=nil, template_source=nil, &block
      if block
        eval(context.instance_eval(&block).map(&:compile).join(';'))
      else
        context.expand(template_source).map(&:compile).join(";")
      end
    end
  end
end