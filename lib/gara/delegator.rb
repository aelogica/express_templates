module Gara

  class Delegator
    attr_accessor :emitter

    def initialize(view_context, emitter)
      @emitter = emitter
      view_context.instance_variable_set(:@gara_delegate, emitter)
      emitter.add_methods_to(view_context)
      yield if block_given?
    end

    def render
      @emitter.emit
    end

  end
end