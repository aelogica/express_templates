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
          def render_with_children(context, *child_markup_src)
            _wrap_using(:markup,context) do
              child_markup_src.join
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
            "#{self.class.to_s}.render_with_children(self, #{children.map(&:compile).join(', ')})"
          end

        end
      end
    end
  end
end