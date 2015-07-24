module ExpressTemplates
  module Components
    module Forms
      class Submit < FormComponent

        has_option :button_class, 'The css class of the input button.'
        has_option :value, 'The value of the submit tag.  Text show in button.',
                           default: 'Save'

        contains -> {
          submit_tag(value, input_attributes)
        }

        before_build(exclusive: true) {
          add_class(config[:wrapper_class])
          remove_class('submit')
        }

        def resource_name
          parent_form ? super : nil
        end

        def value
          config[:value]
        end

      end
    end
  end
end
