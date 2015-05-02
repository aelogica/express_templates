module ExpressTemplates
  module Components
    module Forms
      class ExpressForm < Base
        include Capabilities::Configurable
        include Capabilities::Parenting

        emits -> {
          form {
            form_rails_support form_method
            _yield
          }
        }

        def form_args
          default_args = {action: _action(resource_name), method: :post}

          if @form_options.nil?
            default_args
          else
            if html_options = @form_options.delete(:html_options)
              @form_options.merge!(html_options)
            end
            default_args.merge!(@form_options)
          end
        end

        def resource_name
          my[:id].to_s
        end

        def form_method
          if @_method == :put
            :patch
          else
            @form_options.present? ?  @form_options[:method] : :post
          end
        end

      end
    end
  end
end

