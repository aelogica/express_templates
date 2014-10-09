module ExpressTemplates
  module Components
    module Capabilities
      module Parenting
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