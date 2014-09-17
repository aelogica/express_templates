require 'gara/components'
module Gara
  class Expander

    cattr_accessor :module_search_space

    attr_accessor :stack

    def self.expand(template, source)
      expanded = new(template).expand(source)
      compiled = expanded.map(&:compile)
      return compiled.join("+")
    end

    def initialize(template)
      @template = template
      @stack = Stack.new
    end

    def expand(source=nil, &block)
      if source
        instance_eval(source)
        stack.current
      else
        instance_eval &block
        stack.current
      end
    end

    # define a "macro" method for a component
    # these methods accept args which are passed to the
    # initializer for the component
    # blocks supplied are evaluated and any returned objects are
    # added as children to the component
    def self.register_macros_for(*components)
      components.each do |component|
        define_method(component.macro_name.to_sym) do |*args, &block|
            stack << if block
                begin
                  stack.descend!
                  block.call
                  # anything stored on stack.current or on stack.next is added as a child
                  # this is a bit problematic in the case where we would have
                  # blocks and helpers or locals mixed
                  component.new(*(args.push(*(stack.current + stack.next))))
                ensure
                  stack.ascend!
                end
              else
                component.new(*(args.push(*(stack.next))))
              end
        end
      end
    end


    @module_search_space = [Gara::Components]

    @module_search_space.each do |mod|
      register_macros_for(*
        mod.constants.map { |const| [mod.to_s, const.to_s].join("::").constantize }.
          select { |klass| klass.ancestors.include? (Gara::Component) }
      )
    end

    def method_missing(name, *args)
      # if @stack[@frame+1].nil?
      #   Gara::Components::Wrapper.new(name.to_s, *args)
      # else
        stack.next << Gara::Components::Wrapper.new(name.to_s, *args)
        nil
      # end
    end

    class Stack
      def initialize
        @stack = [[]]
        @frame = 0
      end

      def all
        @stack
      end

      def dump
        puts "Current frame: #{@frame}"
        puts all.map(&:inspect).join("\n")
      end

      def <<(child)
        current << child
        child
      end

      def current
        @stack[@frame]
      end

      def next
        @stack[@frame+1] ||= []
      end

      def descend!
        @frame += 1
        @stack[@frame] ||= []
        @stack[@frame].clear
        @frame
      end

      def ascend!
        raise "Cannot ascend" if @frame <= 0
        current.clear ;
        self.next.clear
        @frame -= 1
      end
    end
  end
end