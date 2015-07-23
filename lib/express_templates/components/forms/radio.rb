module ExpressTemplates
  module Components
    module Forms
      class Radio < FormComponent
        include OptionSupport

        has_option :options, 'Supplies a list of options for the radio tag'
        has_option :label_wrapper_class, 'Specify a class for labels which wrap each radio option.'

        contains -> {
          label_tag(label_name, label_text)
          if option_values_specified?
            generate_options_from_specified_values
          else
            use_options_from_collection_radio_buttons_helper
          end
        }

        def use_options_from_collection_radio_buttons_helper
          collection_radio_buttons(resource_var, field_name.to_sym, collection_from_association,
                                   option_value_method, option_name_method,
                                   input_attributes) do |b|
            b.label(class: "radio") {
              b.radio_button + b.text
            }
          end
        end

        def option_values_specified?
          [Array, Hash].include?(option_collection.class)
        end

        def option_collection
          config[:options]
        end

        def generate_options_from_specified_values
          case
          when option_collection.kind_of?(Array)
            option_collection.each_with_index do |option, index|
              label(class: config[:label_wrapper_class]) {
                radio_button(resource_var, field_name.to_sym, option, class: 'radio')
                current_arbre_element.add_child option
              }
            end
          when option_collection.kind_of?(Hash)
            option_collection.each_pair do |key, value|
              label(class: config[:label_wrapper_class]) {
                radio_button(resource_var, field_name.to_sym, key, class: 'radio')
                current_arbre_element.add_child  value
              }
            end
          else
            raise "Radio collection should be Array or Hash: #{option_collection.inspect}"
          end
        end

        def collection_from_association
          related_collection or raise "No association collection for: #{resource_name}.#{field_name}"
        end

      end
    end
  end
end
