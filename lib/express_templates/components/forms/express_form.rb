module ExpressTemplates
  module Components
    module Forms
      class ExpressForm < Base
        include Capabilities::Configurable
        include Capabilities::Parenting

        emits -> {
          form( form_args ) {
            form_rails_support form_method
            _yield
          }
        }

        def form_id
          "#{resource_name}_{{@#{resource_name}.id}}"
        end

        def form_method
          @config[:method] || :post
        end

        def form_action
          if _modifying_resource?
            "{{#{resource_name}_path(@#{resource_name})}}"
          else # posting a new to a collection
            "{{#{resource_name.pluralize}_path}}"
          end
        end


        def form_args
          args = {id: form_id, action: form_action, method: form_method}

          if html_options = @config.delete(:html_options)
            args.merge!(html_options)
          end
          args[:method] = args[:method].to_s.upcase
          args
        end

        def resource_name
          my[:id].to_s
        end


        private

          def _modifying_resource?
            [:put, :patch].include? form_method
          end

      end
    end
  end
end

