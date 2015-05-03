module ExpressTemplates
  module Components
    module Forms
      # Provides a form Select component based on the Rails *select_tag* helper.
      # Parameters:
      # field_name, select_options, helper_options
      #
      # Select options may be specified as an Array or Hash which will be
      # supplied to the *options_for_select* helper.
      #
      # If the select_options are omitted, the component attempts to check
      # whether the field is an association.  If an association exists,
      # the options will be generated using *options_from_collection_for_select*
      # with the assumption that :id and :name are the value and name fields
      # on the collection.  If no association exists, we use all the existing
      # unique values for the field on the collection to which the resource belongs
      # as the list of possible values for the select.
      class Select < FormComponent
        include Selectable

        emits -> {
          label_tag(label_name, label_text)
          select_tag(field_name_attribute, select_options, field_options)
        }

        # Returns the options which will be supplied to the select_tag helper.
        def select_options
          options_specified = [Array, Hash].include?(@args.second.class)
          if options_specified
            options = @args.second
          else
            options = "@#{resource_name}.pluck(:#{field_name}).distinct"
          end

          if belongs_to_association && !options_specified
            "{{options_from_collection_for_select(#{related_collection}, :id, :name, @#{resource_name}.#{field_name})}}"
          else
            if selection = field_options.delete(:selected)
              "{{options_for_select(#{options}, \"#{selection}\")}}"
            else
              "{{options_for_select(#{options}, @#{resource_name}.#{field_name})}}"
            end
          end
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

      end
    end
  end
end