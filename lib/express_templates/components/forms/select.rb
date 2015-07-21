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
          args = [field_name_attribute, select_options, select_helper_options]
          args
        end

        def select_options_supplied?
          [Array, Hash, Proc].include?(supplied_component_options[:options].class)
        end

        def use_supplied_options
          opts = supplied_component_options[:options]
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
          field_options[:selected]||resource.send(field_name)
        end

        def options_from_supplied_or_field_values
          if select_options_supplied?
            helpers.options_for_select(
                normalize_for_helper(use_supplied_options),
                selected_value
            )
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

        def field_options
          # If field_otions is omitted the Expander will be
          # in last or 3rd position and we don't want that
          defaults = {include_blank: true}
          defaults.merge(supplied_component_options)
        end

        def select_helper_options
          component_option_names = [:select2, :options, :selected]
          add_select2_class( field_options.reject {|k,v| component_option_names.include?(k)})
        end

        protected

          def add_select2_class(helper_options)
            add_class(helper_options[:class]) if helper_options[:class]
            add_class('select2') if supplied_component_options[:select2] === true
            helper_options[:class] = (class_list - ["select"]).to_s
            helper_options
          end

          def supplied_component_options
            if @args.last && @args.last.is_a?(Hash)
              @args.last
            else
              {}
            end
          end

      end
    end
  end
end
