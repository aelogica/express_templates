require 'gara/components'
module Gara
  class Expander

    cattr_accessor :module_search_space

    def self.expand(template, source)
      new(template).expand(source).map(&:compile).join("+")
    end

    def initialize(template)
      @template = template
      @stack = [] ; @frame = -1
    end

    def expand(source=nil, &block)
      if source
        instance_eval(source)
      else
        instance_eval &block
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
          begin
            @stack.push [] ; @frame+=1;
            @stack[@frame] << if block
                # add objects returned from the block as children
                component.new(*(args.push(*block.call)))
              else
                component.new(*args)
              end
            return @stack[@frame]
          ensure
            @frame-=1
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

  end
end