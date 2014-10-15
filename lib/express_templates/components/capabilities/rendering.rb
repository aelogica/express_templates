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
            include InstanceMethods
          end
        end

        module ClassMethods

          # Store a block of logic which will be evalutated in a context
          # during rendering.
          #
          # The block will be passed a reference to the component's class.
          #
          def using_logic(&block)
            @control_flow = block
          end

          # Returns a string containing markup generated by evaluating
          # blocks of supplied logic or compiled template code in a <tt>context</tt>.
          #
          # The context may be any object however, it is generally an
          # ActionView::Context.
          #
          # Components when compiled may yield something like:
          #
          #     "MyComponent.render(self, {id: 'foo'})"
          #
          # The supplied options hash may be used to modify any fragments
          # or the behavior of any logic.
          #
          # If a fragment identifier is passed as a symbol in the first
          # option position, this will render that fragment only.
          #
          def render(context, *opts, &context_logic_block)
            fragment = opts.shift if opts.first.is_a?(Symbol)
            begin
              if fragment
                context.instance_eval(_lookup(fragment, opts)) || ''
              else
                flow = context_logic_block || @control_flow
                exec_args = [self, opts].take(flow.arity)
                context.instance_exec(*exec_args, &flow) || ''
              end
            rescue => e
              binding.pry if ENV['DEBUG'].eql?("true")
              raise "Rendering error in #{self}: #{e.to_s}"
            end
          end

          private

            def _control_flow
              @control_flow
            end

        end

        module InstanceMethods

          def compile
            if _provides_logic?
              "#{self.class.to_s}.render(self)"
            else
              lookup :markup
            end
          end

          private

            def _provides_logic?
              !!self.class.send(:_control_flow)
            end

        end
      end
    end
  end
end
