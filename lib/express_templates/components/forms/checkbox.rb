module ExpressTemplates
  module Components
    module Forms
      class Checkbox < FormComponent

        has_option :label_after, 'Positions the option label after the checkbox.', default: false

        contains {
          label_tag(label_name, label_text) if label_before?
          check_box(resource_name, field_name.to_sym, field_options, checked_value, unchecked_value)
          label_tag(label_name, label_text) if label_after?
        }

        def label_before?
          !label_after?
        end

        def label_after?
          !!config[:label_after]
        end

        def field_options
          {}
        end

        def checked_value
          "1"
        end

        def unchecked_value
          "0"
        end

      end
    end
  end
end