module ExpressTemplates
  module Components
    module Capabilities

      # Add the ability for a component template to wrap or decorate a fragment
      # with another fragment.
      #
      # The insertion point for the inner fragment is marked with <tt>_yield</tt>
      #
      # Example:
      #
      #   class MenuComponent < ExpressTemplates::Components::Base
      #
      #     fragments :menu_item, -> { li { menu_link(item) } },
      #               :menu_wrapper, -> { ul { _yield } }
      #
      #     for_each -> { menu_items }
      #
      #     wrap_with :menu_wrapper
      #
      #   end
      #
      # Note this example also uses Capabilities::Iterating.
      #
      # Provides:
      #
      # * Wrapping::ClassMethods
      #
      module Wrapping
        def self.included(base)
          base.class_eval do
            extend ClassMethods
            include InstanceMethods
          end
        end

        module InstanceMethods
          def compile
            lookup :markup
          end
        end

        module ClassMethods

          # Enclose whatever the component would already generate
          # inside the specified fragment wherever we encounter _yield
          def wrap_with(fragment, dont_wrap_if: false )
            wrapper_name(fragment)
            wrapper_src = _lookup(fragment).source
            inner_src = _lookup(:markup).source_body
            wrapped_src = wrapper_src.gsub!(/\W_yield\W/, inner_src)

            fragment_src = if dont_wrap_if
              %Q(-> {
  unless_block(Proc.from_source(#{dont_wrap_if.source.inspect}), alt: Proc.from_source(%q(-> {#{inner_src}}))) {
    #{Proc.from_source(wrapped_src).source_body}
  }
})
            else
              wrapped_src
            end

            _store :markup, Proc.from_source(fragment_src)

          end

          def wrapper_name(name = nil)
            if name.nil?
              @wrapper_name || :markup
            else
              @wrapper_name = name
            end
          end

          def _yield(*args)
            "{{_yield}}"
          end

        end

      end
    end
  end
end