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
            "{{#{resource_name_for_path}_path(@#{resource_name})}}"
          else # posting a new to a collection
            # We also have to take in to account singular resources 
            # e.g. resource :config -> will throw an unknown method error of configs_path
            "{{#{resource_name_for_path.pluralize}_path}}"
          end
        end


        def form_args
          # there are no put/patch emthods in HTML5, so we have to enforce post
          # need to find a better way to do this: id/action can be overridden but method
          # should always be :post IN THE FORM TAG
          args = {id: form_id, action: form_action}.merge!(@config).merge!(method: :post)

          if html_options = args.delete(:html_options)
            args.merge!(html_options)
          end
          args[:method] = args[:method].to_s.upcase
          args
        end

        def resource_name_for_path
          @config[:id].to_s
        end

        def resource_name
          (@config[:resource_name] || @config[:id]).to_s
        end


        private

          def _modifying_resource?
            [:put, :patch].include? form_method
          end

      end
    end
  end
end

