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

          def _wrap_using(label, context=nil, options={}, &to_be_wrapped)
            body = ''
            if to_be_wrapped
              body = render((context||Object.new), &to_be_wrapped)
            end
            if compiled_src = _lookup(label, options)
              if context.nil?
                eval(compiled_src).gsub(/\{\{_yield\}\}/, body)
              else
                ctx = context.instance_eval("binding")
                ctx.local_variable_set(:_yield, body)
                ctx.eval(compiled_src)
              end
            else
              raise "No wrapper fragment provided for '#{label}'"
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