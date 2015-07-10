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
        include OptionSupport

        emits -> {
          div(class: field_wrapper_class) {
            label_tag(label_name, label_text)
            select_tag(*select_tag_args)
          }
        }

        def select_tag_args
          args = [field_name_attribute, select_options, field_options]
          args << html_options unless html_options.nil? or html_options.empty?
          args
        end

        # Returns the options which will be supplied to the select_tag helper.
        def select_options
          options_specified = [Array, Hash, Proc].include?(@args.second.class) && @args.size > 2
          if options_specified
            if @args.second.respond_to?(:source) # can be a proc
              options = "#{@args.second.source}.call()"
            else
              options = @args.second
            end

          else
            options = "@#{resource_var}.class.distinct(:#{field_name}).pluck(:#{field_name})"
          end

          if belongs_to_association && !options_specified
            if belongs_to_association.polymorphic?
              "{{options_for_select([[]])}}"
            else
              "{{options_from_collection_for_select(#{related_collection}, :id, :#{option_name_method}, @#{resource_name}.#{field_name})}}"
            end
          elsif has_many_through_association
            "{{options_from_collection_for_select(#{related_collection}, :id, :#{option_name_method}, @#{resource_name}.#{field_name}.map(&:id))}}"
          else
            if selection = field_options.delete(:selected)
              "{{options_for_select(#{options}, \"#{selection}\")}}"
            else
              "{{options_for_select(#{options}, @#{resource_name}.#{field_name})}}"
            end
          end
        end

        def field_name_attribute
          if has_many_through_association
            "#{resource_name.singularize}[#{field_name.singularize}_ids]"
          else
            super
          end
        end

        def field_options
          # If field_otions is omitted the Expander will be
          # in last or 3rd position and we don't want that
          defaults = {include_blank: true}

          if supplied_field_options[:select2]
            if klasses = supplied_field_options[:class]
              supplied_field_options[:class] << ' select2'
            else
              defaults.merge!(class: 'select2')
            end
          end

          defaults.merge(supplied_field_options.reject {|k,v| k.eql?(:select2)})
        end

        def html_options
          supplied_html_options
        end

        protected

          def supplied_field_options
            if @args.size > 3 && @args[2].is_a?(Hash)
              @args[2]
            else
              {}
            end
          end

          def supplied_html_options
            if @args.size > 4 && @args[3].is_a?(Hash)
              @args[3]
            else
              {}
            end
          end

      end
    end
  end
end
