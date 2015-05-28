module ExpressTemplates
  module Components
    module Forms
      class FormComponent < Base
        include Capabilities::Configurable
        include Capabilities::Adoptable

        def compile(*args)
          raise "#{self.class} requires a parent ExpressForm" if parent.nil? or parent_form.nil?
          super(*args)
        end

        # Lookup the resource_name from the parent ExpressForm.
        def resource_name
          parent_form.resource_name
        end

        def resource_var
          resource_name.to_sym
        end

        def resource_class
          if namespace = parent_form.namespace
            "#{namespace}/#{resource_name}".classify
          else
            resource_name.classify
          end
        end

        # Return the name attribute for the lable
        def label_name
          "#{resource_name.singularize}_#{field_name}"
        end

        # Return the text content for the label
        def label_text
          @options[:label] || field_name.titleize
        end

        # Return the field_name as a string.  This taken from the first argument
        # to the component macro in the template or fragment.
        def field_name
          (@config[:id] || (@args.first.is_a?(String) && @args.first)).to_s
        end

        # Return the field name attribute.  Currently handles only simple attributes
        # on the resource.  Does not handle attributes for associated resources.
        def field_name_attribute
          "#{resource_name.singularize}[#{field_name}]"
        end

        def field_wrapper_class
          @config[:wrapper_class] || 'field-wrapper'
        end

        # Search the parent graph until we find an ExpressForm.  Returns nil if none found.
        def parent_form
          @my_form ||= parent
          until @my_form.nil? || @my_form.kind_of?(ExpressForm)
            @my_form = @my_form.parent
          end
          return @my_form
        end

      end
    end
  end
end