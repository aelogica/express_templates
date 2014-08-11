module Gara

  class Delegator
    attr_accessor :emitter

    def initialize(view_context, emitter = Html5Emitter.new)
      @emitter = emitter
      view_context.instance_variable_set(:@gara_delegate_target, emitter.target)
      view_context.extend(emitter.delegated_methods)
    end

    def to_html
      emitter.to_html
    end

  end
end