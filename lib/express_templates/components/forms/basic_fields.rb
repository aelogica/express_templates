module ExpressTemplates
  module Components
    module Forms
      module BasicFields
        ALL = %w(email phone text password color date datetime
                datetime_local file number range
                search telephone time url week)

        ALL.each do |type|
          class_definition = <<-RUBY
            class #{type.classify} < FormComponent
              contains {
                label_tag(label_name, label_text)
                #{type}_field resource_name, field_name.to_sym, input_attributes
              }
            end
RUBY

          eval(class_definition)

        end
      end

      # class Email < FormComponent
      #   contains {
      #      label_tag label_name, label_text
      #      email_field resource_name, field_name.to_sym, input_attributes
      #   }
      # end

      class Textarea < FormComponent
        contains {
          label_tag(label_name, label_text)
          text_area resource_name, field_name.to_sym, input_attributes
        }
      end

      class Hidden < FormComponent
        contains {
          hidden_field resource_name, field_name.to_sym, input_attributes
        }
      end
    end
  end
end
