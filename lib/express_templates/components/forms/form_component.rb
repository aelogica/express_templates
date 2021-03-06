module ExpressTemplates
  module Components
    module Forms
      class FormComponent < Configurable

        attr :input_attributes

        before_build -> {
          set_attribute(:id, "#{resource_name}_#{field_name}_wrapper")
          add_class(config[:wrapper_class])
          add_class('error') if resource.respond_to?(:errors) &&
                                resource.errors.include?(field_name.to_sym)
        }

        has_option :wrapper_class, 'Override the class of the wrapping div of a form component', default: 'field-wrapper'
        has_option :label, 'Override the inferred label of a form component'

        def resource
          self.send(resource_name)
        end

        # Lookup the resource_name from the parent ExpressForm.
        def resource_name
          raise "FormComponent must have a parent form" unless parent_form
          parent_form.config[:id].to_s
        end

        def resource_class
          parent_form.resource_class
        end

        # Return the name attribute for the label
        def label_name
          "#{resource_name.singularize}_#{field_name}"
        end

        # Return the text content for the label
        def label_text
          config[:label] || field_name.titleize
        end

        # Return the field_name as a string.  This taken from the first argument
        # to the component macro in the template or fragment.
        def field_name
          (config[:id] || (@args.first.is_a?(String) && @args.first)).to_s
        end

        def field_value
          resource.send(field_name)
        end

        # Return the field name attribute.  Currently handles only simple attributes
        # on the resource.  Does not handle attributes for associated resources.
        def field_name_attribute
          "#{resource_name.singularize}[#{field_name}]"
        end

        def field_id_attribute
          "#{resource_name.singularize}_#{field_name}"
        end

        def field_helper_options
          {id: field_id_attribute}.merge(input_attributes||nil)
        end

        # Search the parent graph until we find an ExpressForm.  Returns nil if none found.
        def parent_form
          @my_form ||= parent
          until @my_form.nil? || @my_form.kind_of?(ExpressForm)
            @my_form = @my_form.parent
          end
          return @my_form
        end

        protected

          # saving attributes for passing to the input field
          def _process_builder_args!(args)
            super(args)
            @input_attributes = args.last if args.last.kind_of?(Hash)
            @input_attributes ||= {}
            args.clear
          end

      end
    end
  end
end
