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
              contains {
                label_tag(label_name, label_text)
                #{type}_field_tag field_name_attribute, field_value, field_helper_options
              }
            end
RUBY

          eval(class_definition)

        end
      end

      # class Email < FormComponent
      #   contains {
      #      label_tag label_name, label_text
      #      email_field  field_name_attribute, field_value, field_helper_options
      #   }
      # end

      class File < FormComponent
        contains {
          label_tag(label_name, label_text)
          file_field_tag field_name_attribute, field_helper_options
        }
      end

      class Textarea < FormComponent
        contains {
          label_tag(label_name, label_text)
          text_area_tag field_name_attribute, field_value, field_helper_options
        }
      end

      class Hidden < FormComponent
        contains {
          hidden_field_tag field_name_attribute, field_value, field_helper_options
        }
      end
    end
  end
end
