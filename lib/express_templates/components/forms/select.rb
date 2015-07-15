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

        def options_specified?
          [Array, Hash, Proc].include?(@args.first.class)
        end

        # Returns the options which will be supplied to the select_tag helper.
        def select_options
          options = if options_specified?
            if @args.first.respond_to?(:call) # can be a proc
              @args.first.call()
            else
              @args.first
            end
          else
            helpers.resource.class.distinct(field_name.to_sym).pluck(field_name.to_sym)
          end

          if belongs_to_association && !options_specified?
            if belongs_to_association.polymorphic?
              helpers.options_for_select([[]])
            else
              helpers.options_from_collection_for_select(related_collection, :id, option_name_method, helpers.resource.send(field_name))
            end
          elsif has_many_through_association
            helpers.options_from_collection_for_select(related_collection, :id, option_name_method, helpers.resource.send(field_name).map(&:id))
          else
            if selection = field_options.delete(:selected)
              helpers.options_for_select(options, selection)
            else
              helpers.options_for_select(options, helpers.resource.send(field_name))
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
            if @args[1] && @args[1].is_a?(Hash)
              @args[1]
            else
              {}
            end
          end

          def supplied_html_options
            if @args[2] && @args[2].is_a?(Hash)
              @args[2]
            else
              {}
            end
          end

      end
    end
  end
end
