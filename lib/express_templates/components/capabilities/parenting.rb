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
            extend ClassMethods
            include InstanceMethods
          end
        end

        module ClassMethods
          def render_with_children(context, locals = {}, child_markup_src = nil)
            _wrap_using(:markup, context, locals) do
              child_markup_src
            end
          end

        end

        module InstanceMethods
          def children
            @children ||= []
          end

          def children=(children)
            @children =children
          end

          def compile
            locals = (expand_locals rescue nil).inspect
            children_markup = children.map(&:compile).join('+')
            "#{self.class.to_s}.render_with_children(self, #{locals}, (#{children_markup}))"
          end

        end
      end
    end
  end
end