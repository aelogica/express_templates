module ExpressTemplates
  module Components
    module Forms
      class ExpressForm < Container
        include ExpressTemplates::Components::Capabilities::Resourceful

        tag :form

        has_option :method, 'The form method', default: 'POST', attribute: true #, options: ['PUT', 'POST', 'GET', 'DELETE']
        has_option :action, 'The form action containing the resource path or url.'

        prepends -> {
          div(style: 'display:none') {
            add_child helpers.utf8_enforcer_tag
            add_child helpers.send(:method_tag, resource.persisted? ? :put : :post)
            helpers.send(:token_tag)
          }
        }

        before_build -> {
          set_attribute(:id, form_id)
          set_attribute(:action, form_action)
          add_class(config[:id])
        }

        def form_id
          [config[:id], resource.try(:id)].compact.join('_')
        end

        def form_action
          config[:action] || (resource.try(:persisted?) ? resource_path(ivar: true) : collection_path)
        end

      end
    end
  end
end

