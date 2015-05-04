module ExpressTemplates
  module Components
    module Forms
      module BasicFields
        ALL = %w(email phone text password color date datetime
                datetime_local hidden number range
                search telephone time url week)

        ALL.each do |type|
          class_definition = <<-RUBY
            class #{type.classify} < FormComponent
              emits -> {
                div(class: field_wrapper_class) {
                  #{type}_field resource_var, field_name.to_sym
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
            text_area resource_var, field_name.to_sym
          }
        }
      end


    end
  end
end

