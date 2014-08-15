module Gara

  class Delegator
    attr_accessor :emitter

    # def h1(*args, &block) {
    #   @gara_delegate.h1(*args) {
    #     result = (yield if block_given?)
    #     if after_processor.respond_to?(:call)
    #       after_processor.call(self, result)
    #     end
    #   }
    # }

    def self.define_delegate(method_name, on: nil, to: nil, after_processor: nil)
      on.module_eval do
        define_method method_name do |*args|
          @gara_delegate.send(method_name, *args) { yield if block_given?}
        end
      end
    end


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