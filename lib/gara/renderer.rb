module Gara
  module Renderer
    def render context, &block
      context.capture(&block) if block_given?
    end
  end
end