module ExpressTemplates
  module Components
    module Forms
      module BasicFields
        ALL = %w(email phone text password color date datetime
                datetime_local number range
                search telephone time url week)

        ALL.each do |type|
          class_definition = <<-RUBY
            class #{type.classify} < FormComponent
              emits -> {
                div(class: field_wrapper_class) {
                  label_tag(label_name, label_text)
                  #{type}_field resource_var, field_name.to_sym, html_options
                }
              }
            end
RUBY

          eval(class_definition)

        end
      end

      # class Email < FormComponent
      #   emits -> {
      #     div(class: field_wrapper_class) {
      #       email_field resource_var, field_name.to_sym
      #     }
      #   }
      # end

      class Textarea < FormComponent
        emits -> {
          div(class: field_wrapper_class) {
            label_tag(label_name, label_text)
            text_area resource_var, field_name.to_sym, html_options
          }
        }
      end

      class Hidden < FormComponent
        emits -> {
          hidden_field resource_var, field_name.to_sym, html_options
        }
      end
    end
  end
end
