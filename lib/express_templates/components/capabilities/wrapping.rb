module ExpressTemplates
  module Components
    module Capabilities
      module Wrapping
        def self.included(base)
          base.class_eval do
            extend ClassMethods
          end
        end

        module ClassMethods

          def wrap_with(fragment)
            prior_logic = @control_flow
            using_logic do |component|
              component._wrap_using(fragment, self, &prior_logic)
            end
          end

          def insert(label)
            eval(_lookup(label))
          end

          def _wrap_using(label, context=nil, &to_be_wrapped)
            body = ''
            if to_be_wrapped && context
              body = render(context, &to_be_wrapped)
            end
            insert(label).gsub(/\{\{_yield\}\}/, body)
          end

          def _yield(*args)
            "{{_yield}}"
          end

        end

      end
    end
  end
end