module ExpressTemplates
  module Components
    module Capabilities
      module Rendering
        def self.included(base)
          base.class_eval do
            extend ClassMethods
            include InstanceMethods
          end
        end

        module ClassMethods
          def using_logic(&block)
            @control_flow = block
          end

          def render(context, fragment=nil, &block)
            begin
              if fragment
                context.instance_eval(_lookup(fragment)) || ''
              else
                flow = block || @control_flow
                context.instance_exec(self, &flow) || ''
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
              self.class[:markup]
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
