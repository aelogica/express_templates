module Gara
  module Renderer
    def render context=nil, &block
      eval(context.instance_eval(&block).map(&:compile).join(';'))
    end
  end
end