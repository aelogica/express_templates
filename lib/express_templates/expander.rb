require 'express_templates/components'
module ExpressTemplates
  class Expander

    cattr_accessor :module_search_space

    attr_accessor :stack, :handlers, :locals, :template

    def initialize(*args)
      initialize_expander(*args)
    end

    def initialize_expander(template, handlers = {}, locals = {})
      @template = template
      @stack = Stack.new
      @handlers = handlers
      @locals = locals
      self
    end

    def expand(source=nil, &block)
      case
      when block.nil? && source
        modified = _replace_yield_with_yielder(source)
        instance_eval(modified, @template.inspect)
      when block
        instance_exec &block
      else
        raise ArgumentError
      end
      stack.current
    end

    def process_children!(parent, &block)
      begin
        stack.descend!
        result = instance_exec &block
        if stack.current.empty? && result.is_a?(String)
          stack << result
        end
        parent.children += stack.current
        stack.ascend!
      end
      stack.current
    end

    # define a "macro" method for a component
    # these methods accept args which are passed to the
    # initializer for the component
    # blocks supplied are evaluated and children added to the "stack"
    # are added as children to the component
    def self.register_macros_for(*components)
      components.each do |component|
        define_method(component.macro_name.to_sym) do |*args, &block|
            new_component = nil
            # this is a code smell here.
            if component.ancestors.include?(Components::Capabilities::Building)
              new_component = component.new(*(args.push(self)), &block)
            else
              new_component = component.new(*(args.push(self)))
              process_children!(new_component, &block) unless block.nil?
            end
            stack << new_component
        end
      end
    end


    @module_search_space = [ExpressTemplates::Markup, ExpressTemplates::Components]

    @module_search_space.each do |mod|
      register_macros_for(*
        mod.constants.map { |const| [mod.to_s, const.to_s].join("::").constantize }.
          select { |klass| klass.ancestors.include? (ExpressTemplates::Markup::Tag) }
      )
    end

    def method_missing(name, *args, &block)
      raise "#{self.class} unexpected macro: \"#{name}\"." if locals.nil?
      return locals[name] if locals.keys.include?(name)

      if handlers.keys.include?(name)
        stack << handlers[name].send(name, *args, &block)
      else
        stack << ExpressTemplates::Markup::Wrapper.new(name.to_s, *args, &block)
      end
      nil
    end

    private

      def _replace_yield_with_yielder(source)
        source.gsub(/(\W)(yield)(\([^\)]*\))?/, '\1 (stack << ExpressTemplates::Markup::Yielder.new\3)')
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
        require 'pp'
        pp all
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
