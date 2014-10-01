require 'express_templates/components'
module ExpressTemplates
  class Expander

    cattr_accessor :module_search_space

    attr_accessor :stack

    def initialize(template)
      @template = template
      @stack = Stack.new
    end

    def expand(source=nil, &block)
      case
      when block.nil? && source
        modified = source.gsub(/(\W)(yield)(\([^\)]*\))?/, '\1 (stack << ExpressTemplates::Markup::Yielder.new\3)')
        modified.gsub!(/(\W)(@\w+)(\W)?/, '\1 (stack << ExpressTemplates::Markup::Wrapper.new("\2") )\3')
        instance_eval(modified, @template.inspect)
      when block
        instance_exec &block
        stack.current
      else
        raise ArgumentError
      end
      stack.current
    end

    def process_children!(parent, &block)
      begin
        stack.descend!
        instance_exec &block
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
            new_component = component.new(*(args.push(self)))
            process_children!(new_component, &block) unless block.nil?
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

    def method_missing(name, *args)
      stack << ExpressTemplates::Markup::Wrapper.new(name.to_s, *args)
      nil
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