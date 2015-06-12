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
      class SelectCollection < Select

        emits -> {
          div(class: field_wrapper_class) {
            label_tag(label_name, label_text)

            # need this because the collection_select helper does not provide
            # the hidden_field_tag trick (see rails api docs for select)
            hidden_field_tag(multi_field_name, '')

            collection_select(*collection_select_tag_args)
          }
        }

        def collection_select_tag_args
          [ resource_name,
            multi_field_name,
            select_options, :id, :name,
            field_options,
            html_options ]
        end

        def field_options
          selected_options_ruby = "@#{resource_name}.#{multi_field_name}".to_view_code
          super.merge(include_blank: false, selected: selected_options_ruby)
        end

        def html_options
          (super||{}).merge(multiple: true)
        end

        def multi_field_name
          if has_many_through_association
            "#{field_name.singularize}_ids"
          else
            raise "Only use select_collection for has_many :through.  #{field_name} is not has_many :through"
          end
        end


        def select_options
          "{{#{related_collection}}}"
        end
      end
    end
  end
end