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
            _wrap_it(context, locals) do |component|
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
            compiled_children = nil
            args = %w(self)
            args << locals
            Indenter.for(:compile) do |indent, indent_with_newline|
              compiled_children = children.map { |child| indent_with_newline + child.compile }.join("+")
              compiled_children.gsub!('"+"', '') # avoid unnecessary string concatenation
              args << compiled_children unless compiled_children.empty?
            end
            closing_paren = compiled_children.empty? ? ')' : "\n#{Indenter.for(:compile)})"
            "#{self.class.to_s}.render_with_children(#{args.join(', ')}#{closing_paren}"
          end

        end
      end
    end
  end
end