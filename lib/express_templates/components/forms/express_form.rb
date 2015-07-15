module ExpressTemplates
  module Components
    module Forms
      class ExpressForm < Configurable
        include ExpressTemplates::Components::Capabilities::Resourceful

        emits -> (block) {
          form(form_tag_options ) {
            form_rails_support form_method
            block.call(self) if block
          }
        }

        def form_id
          "#{resource_name}_#{helpers.resource.id}"
        end

        def form_method
          config[:method].to_s.upcase || 'POST'
        end

        def form_action
          config[:action] || (helpers.resource.try(:persisted?) ? resource_path(ivar: true) : collection_path)
        end

        def form_tag_options
          args = {id: form_id, action: form_action}.merge!(config).merge!(method: 'POST')

          if html_options = args.delete(:html_options)
            args.merge!(html_options)
          end
          args
        end

        def resource_name_for_path
          config[:id].to_s
        end

        def resource_name
          (config[:resource_name] || config[:id]).to_s
        end

      end
    end
  end
end

