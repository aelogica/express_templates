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
      #     wrap_with :wrapper
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
          end
        end

        module ClassMethods

          # Enclose whatever the component would already generate
          # inside the specified fragment wherever we encounter _yield
          #
          # Note: this must come after any statements that affect the logic
          # flow.
          def wrap_with(fragment, dont_wrap_if: -> {false} )
            wrapper_name(fragment)
            prior_logic = @control_flow
            using_logic do |component|
              if instance_exec(&dont_wrap_if)
                eval(component.render((self||Object.new), &prior_logic))
              else
                component._wrap_it(self, &prior_logic)
              end
            end
          end

          def wrapper_name(name = nil)
            if name.nil?
              @wrapper_name || :markup
            else
              @wrapper_name = name
            end
          end

          # added back in for compatability with prior interface
          # should probably be refactored away
          def _wrap_using(fragment, context=nil, options={}, &to_be_wrapped)
            old_wrapper_name = @wrapper_name
            @wrapper_name = fragment
            result = _wrap_it(context, options, &to_be_wrapped)
            @wrapper_name = old_wrapper_name
            return result
          end

          def _wrap_it(context=nil, options={}, &to_be_wrapped)
            body = ''
            if to_be_wrapped
              body = render((context||Object.new), &to_be_wrapped)
            end
            if compiled_src = _lookup(wrapper_name, options)
              if context.nil?
                eval(compiled_src).gsub(/\{\{_yield\}\}/, body)
              else
                ctx = context.instance_eval("binding")
                ctx.local_variable_set(:_yield, body)
                ctx.eval(compiled_src)
              end
            else
              raise "No wrapper fragment provided for '#{wrapper_name}'"
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