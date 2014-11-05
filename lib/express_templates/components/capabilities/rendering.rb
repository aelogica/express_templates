module ExpressTemplates
  module Components
    module Capabilities

      # Adds the capability for a component to render itself in a context.
      #
      # Provides both:
      #
      # * Rendering::ClassMethods
      # * Rendering::InstanceMethods
      #
      # Used in ExpressTemplates::Components::Base.
      #
      module Rendering
        def self.included(base)
          base.class_eval do
            extend ClassMethods
          end
        end

        module ClassMethods
          def render_in(context, &view_code)
            context.instance_eval(&view_code)
          end
        end

      end
    end
  end
end
