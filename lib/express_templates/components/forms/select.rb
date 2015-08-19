module ExpressTemplates
  module Components
    module Forms
      # Provides a form Select component based on the Rails *select_tag* helper.
      #
      # The :options may be specified as an Array or Hash which will be
      # supplied to the *options_for_select* helper.
      #
      # If the :options are omitted, the component attempts to check
      # whether the field is an association.  If an association exists,
      # the options will be generated using *options_from_collection_for_select*
      # with the assumption that :id and :name are the value and name fields
      # on the collection.  If no association exists, we use all the existing
      # unique values for the field on the collection to which the resource belongs
      # as the list of possible values for the select.
      class Select < FormComponent
        include OptionSupport

        has_option :options, 'Select options. Can be Array, Hash, or Proc.'
        has_option :selected, 'The currently selected value; Used when options are supplied. Otherwise the value is taken from the resource.'
        has_option :include_blank, 'Whether or not to include a blank option.', default: true
        has_option :select2, 'Use select2 enhanced select box.', default: true

        contains -> {
          label_tag(label_name, label_text)
          select_tag(*select_tag_args)
        }

        def select_tag_args
          [field_name_attribute, select_options, select_helper_options]
        end

        def select_options_supplied?
          [Array, Hash, Proc].include?(config[:options].class)
        end

        def use_supplied_options
          opts = config[:options]
          if opts.respond_to?(:call) # can be a proc
            opts.call(resource)
          else
            opts
          end
        end

        def generate_options_from_field_values
          resource.class.distinct(field_name.to_sym).pluck(field_name.to_sym)
        end

        def normalize_for_helper(supplied_options)
          supplied_options.map do |opt|
            [opt.respond_to?(:name) ? opt.name : opt.to_s,
             opt.respond_to?(:id) ? opt.id : opt.to_s]
          end
        end

        def selected_value
          config[:selected]||resource.send(field_name)
        end

        def options_from_supplied_or_field_values
          if select_options_supplied?
            supplied_options = use_supplied_options
            if supplied_options.respond_to?(:map)
              helpers.options_for_select(
                  normalize_for_helper(supplied_options),
                  selected_value)
            else
              supplied_options
            end
          else
            generate_options_from_field_values
          end
        end

        def options_from_belongs_to
          if belongs_to_association.polymorphic?
            helpers.options_for_select([[]]) # we can't really handle polymorhic yet
          else
            helpers.options_from_collection_for_select(related_collection, :id, option_name_method, resource.send(field_name))
          end
        end

        def options_from_has_many_through
          helpers.options_from_collection_for_select(related_collection, :id, option_name_method, resource.send(field_name).map(&:id))
        end

        def simple_options_with_selection
          helpers.options_for_select(options_from_supplied_or_field_values, selected_value)
        end

        # Returns the options which will be supplied to the select_tag helper.
        def select_options
          if belongs_to_association && !select_options_supplied?
            options_from_belongs_to
          elsif has_many_through_association
            options_from_has_many_through
          else
            simple_options_with_selection
          end
        end

        def field_name_attribute
          if has_many_through_association
            "#{resource_name.singularize}[#{field_name.singularize}_ids]"
          else
            super
          end
        end

        def select_helper_options
          add_select2_class( input_attributes.merge(include_blank: !!config[:include_blank]) )
        end

        protected

          def add_select2_class(helper_options)
            classes = (helper_options[:class]||'').split(' ')
            classes << 'select2' if config[:select2] === true
            helper_options.merge(:class => classes.join(' '))
          end

      end
    end
  end
end
