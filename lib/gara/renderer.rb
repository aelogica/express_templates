module Gara
  module Renderer
    def render context, emitter = Html5Emitter.new, &block
      Gara::Delegator.new(context, emitter, &block).render
    end
  end
end