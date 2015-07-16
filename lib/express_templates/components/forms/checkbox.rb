module ExpressTemplates
  module Components
    module Forms
      class Checkbox < FormComponent

        emits -> {
          div(class: field_wrapper_class) {
            label_tag(label_name, label_text) if label_before?
            check_box(resource_var, field_name.to_sym, field_options, checked_value, unchecked_value)
            label_tag(label_name, label_text) if label_after?
          }
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