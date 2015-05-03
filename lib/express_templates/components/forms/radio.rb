module ExpressTemplates
  module Components
    module Forms
      class Radio < FormComponent
        include OptionSupport

        emits -> {
          div(class: field_wrapper_class) {
            label_tag(label_name, label_text)
            if option_values_specified?
              generate_options_from_specified_values
            else
              use_options_from_collection_radio_buttons_helper
            end
          }
        }

        def use_options_from_collection_radio_buttons_helper
          collection_radio_buttons(resource_name, field_name, collection_from_association,
                                   option_value_method, option_name_method,
                                   field_options, html_options) do |b|
            b.label(class: "radio") {
              b.radio_button + b.text
            }
          end
        end

        def option_values_specified?
          [Array, Hash].include?(option_collection.class)
        end

        def option_collection
          @args.second
        end

        def generate_options_from_specified_values
          case
          when option_collection.kind_of?(Array)
            option_collection.each_with_index do |option, index|
              label_tag("#{resource_name}_#{field_name}_#{index}", option.titleize)
              radio_button(resource_name, field_name, option, class: 'radio')
            end
          when option_collection.kind_of?(Hash)
            option_collection.each_pair do |key, value|
              label_tag("#{resource_name}_#{field_name}_#{key}", value.titleize)
              radio_button(resource_name, field_name, key, class: 'radio')
            end
          else
            raise "Radio collection should be Array or Hash: #{option_collection.inspect}"
          end
        end

        def collection_from_association
          related_collection or raise "No association collection for: #{resource_name}.#{field_name}"
        end

        def field_options
          # If field_otions is omitted the Expander will be
          # in last or 3rd position and we don't want that
          if @args.size > 3 && @args[2].is_a?(Hash)
            @args[2]
          else
            {}
          end
        end

        # TODO: implement
        def html_options
          {}
        end

      end
    end
  end
end