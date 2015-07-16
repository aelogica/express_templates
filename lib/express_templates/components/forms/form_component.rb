module ExpressTemplates
  module Components
    module Forms
      class FormComponent < Configurable

        # Lookup the resource_name from the parent ExpressForm.
        def resource_name
          raise "FormComponent must have a parent form" unless parent_form
          parent_form.resource_name
        end

        def resource_var
          resource_name.to_sym
        end

        def resource_class
          parent_form.resource_class
        end

        # Return the name attribute for the lable
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

        # Return the field name attribute.  Currently handles only simple attributes
        # on the resource.  Does not handle attributes for associated resources.
        def field_name_attribute
          "#{resource_name.singularize}[#{field_name}]"
        end

        def field_wrapper_class
          config[:wrapper_class] || 'field-wrapper'
        end

        # Search the parent graph until we find an ExpressForm.  Returns nil if none found.
        def parent_form
          @my_form ||= parent
          until @my_form.nil? || @my_form.kind_of?(ExpressForm)
            @my_form = @my_form.parent
          end
          return @my_form
        end

        def default_html_options
          (config || {}).reject {|k,v| k.eql?(:id)}
        end

        def html_options
          default_html_options.merge(config[:html_options] || {})
        end

        protected

          def _process_args!(args)
            @args = args
            super(args)
          end

      end
    end
  end
end
