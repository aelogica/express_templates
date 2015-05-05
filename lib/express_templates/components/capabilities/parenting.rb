module ExpressTemplates
  module Components
    module Capabilities
      module Parenting

        # Parenting adds the capability for a component to have and render
        # children that may be specified in the template fragment which
        # includes the component.
        #
        # Example parenting component:
        #
        #   class Line < ExpressTemplates::Components::Base
        #     include Capabilities::Parenting
        #
        #     emits { p.line { _yield } }
        #   end
        #
        # You might then use this component like so:
        #
        #   line "In", "Xanadu", "did", "Kubla", "Khan"
        #   line { "A stately pleasure-dome decree :" }
        #   line { "Where Alph, the sacred river, ran" }
        #   line %q(Through caverns measureless to man)
        #   line %q|Down to a sunless sea.|
        #
        # Provides
        #
        # * ClassMethods for rendering
        # * InstanceMethods for managing children
        #
        def self.included(base)
          base.class_eval do
            include InstanceMethods
          end
        end

        module InstanceMethods
          def children
            @children ||= []
          end

          def children=(children)
            @children = children
            children.each do |child|
              if child.kind_of?(Adoptable)
                child.parent = self
              end
            end
          end

          def compile
            null_wrapped_children = "null_wrap(%q(#{compile_children}))"
            wrap_children_src = self.class[:markup].source.gsub(/(\s)_yield(\s)/, '\1'+null_wrapped_children+'\2')
            _compile_fragment(Proc.from_source(wrap_children_src))
          end

          def compile_children
            compiled_children = nil
            Indenter.for(:compile) do |indent, indent_with_newline|
              compiled_children = children.map do |child|
                indent_with_newline +
                (child.respond_to?(:compile) ? child.compile : child.inspect) # Bare strings may be children
              end.join("+\n")
              compiled_children.gsub!('"+"', '') # avoid unnecessary string concatenation
            end
            return compiled_children
          end
        end
      end
    end
  end
end