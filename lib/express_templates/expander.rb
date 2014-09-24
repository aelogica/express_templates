require 'express_templates/components'
module ExpressTemplates
  class Expander

    cattr_accessor :module_search_space

    attr_accessor :stack

    def self.expand(template, source)
      expanded = new(template).expand(source)
      compiled = expanded.map(&:compile)
      return compiled.join("+").tap {|s| puts("\n"+template.inspect+"\n"+s) if ENV['DEBUG'].eql?('true') }
    end

    def initialize(template)
      @template = template
      @stack = Stack.new
    end

    def expand(source=nil, &block)
      if source
        modified = source.gsub(/(\W)(yield)(\([^\)]*\))?/, '\1 (stack << ExpressTemplates::Markup::Yielder.new\3)')
        modified.gsub!(/(\W)(@\w+)(\W)?/, '\1 (stack << ExpressTemplates::Markup::Wrapper.new("\2") )\3')
        instance_eval(modified, @template.inspect)
        stack.current
      else
        instance_exec &block
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
                  component.new(*(args.push(*(stack.current))))
                ensure
                  stack.ascend!
                end
              else
                component.new(*(args))
              end
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