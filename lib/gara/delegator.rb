module Gara

  class Delegator
    attr_accessor :emitter

    def self.define_delegate(method_name, on: nil, to: nil)
      on.module_eval <<-RUBY
        def #{method_name}(*args)
          #{to || "@gara_delegate"}.#{method_name}(*args) { yield if block_given? }
        end
      RUBY
    end


    def initialize(view_context, emitter)
      @emitter = emitter
      view_context.instance_variable_set(:@gara_delegate, emitter)
      view_context.extend(emitter.registered_methods)
      yield if block_given?
    end

    def render
      @emitter.emit
    end

  end
end