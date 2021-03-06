module ExpressTemplates
  module Components
    module Forms
      # Provides a form Select component based on the Rails *collection_select* helper.
      class SelectCollection < Select

        has_option :multiple, "Allow multiple selections.", default: true

        contains -> {
          label_tag(label_name, label_text)

          # need this because the collection_select helper does not provide
          # the hidden_field_tag trick (see rails api docs for select)
          hidden_field_tag(multi_field_name, '')
          collection_select(*collection_select_tag_args)
        }

        def collection_select_tag_args
          [ resource_name,
            multi_field_name,
            related_collection, :id, :name,
            field_options,
            html_options ]
        end

        def field_options
          {include_blank: !!input_attributes.delete(:include_blank)}
        end

        def html_options
          input_attributes.reject {|k,v| k.eql?(:include_blank)}.merge(multiple: config[:multiple])
        end

        def multi_field_name
          if has_many_through_association
            "#{field_name.singularize}_ids"
          else
            raise "Only use select_collection for has_many :through.  #{field_name} is not has_many :through"
          end
        end

      end
    end
  end
end