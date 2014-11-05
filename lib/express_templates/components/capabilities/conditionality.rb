module ExpressTemplates
  module Components
    module Capabilities
      # Adds the capability for a component to only render
      # its markup when a condition to be evaluated in the
      # view is true.
      #
      # Example:
      #
      #     class PageHeader < ExpressTemplates::Components::Base
      #       include ExpressTemplates::Components::Capabilities::Conditionality
      #
      #         emits {
      #           h1 { content_for(:page_header) }
      #         }
      #
      #         only_if -> { content_for?(:page_header) }
      #
      #       end
      #     end
      #
      # The condition supplied to only if in the form of a proc
      # is evaluated in the view context.
      #
      # The component will render an empty string if the proc returns false.
      module Conditionality
        def self.included(base)
          base.class_eval do
            extend ClassMethods
          end
        end

        module ClassMethods

          def condition_proc
            @condition_proc
          end

          def only_if condition_proc
            @condition_proc = Proc.from_source "-> {!(#{condition_proc.source_body})}"
            inner_src = self[:markup]
            fragment_src = %Q(-> {
  unless_block(Proc.from_source(#{@condition_proc.source.inspect})) {
    #{inner_src.source_body}
  }
})
            _store :markup, Proc.from_source(fragment_src)
          end

        end
      end
    end
  end
end