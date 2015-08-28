module ExpressTemplates
  module Components
    module Forms
      class ExpressForm < Container
        include ExpressTemplates::Components::Capabilities::Resourceful

        tag :form

        has_option :method, 'The form method', default: 'POST', attribute: true #, options: ['PUT', 'POST', 'GET', 'DELETE']
        has_option :action, 'The form action containing the resource path or url.'
        has_option :on_success, 'Pass a form value indicating where to go on a successful submission.'
        has_option :on_failure, 'Pass a form value indicating where to go on a failed submission.'
        has_option :enctype, 'The enctype attribute specifies how the form-data should be encoded when submitting it to the server.'

        prepends -> {
          div(style: 'display:none') {
            add_child helpers.utf8_enforcer_tag
            add_child helpers.send(:method_tag, resource.persisted? ? :put : :post)
            add_child helpers.send(:token_tag)
            hidden_field_tag :on_success, config[:on_success] if config[:on_success]
            hidden_field_tag :on_failure, config[:on_failure] if config[:on_failure]
          }
        }

        before_build -> {
          set_attribute(:id, form_id)
          set_attribute(:action, form_action)
          set_attribute(:enctype, form_enctype) if form_enctype
          add_class(config[:id])
        }

        def form_id
          [config[:id], resource.try(:id)].compact.join('_')
        end

        def form_action
          config[:action] || (resource.try(:persisted?) ? resource_path(resource) : collection_path)
        end

        def form_enctype
          config[:enctype]
        end

      end
    end
  end
end

