module ExpressTemplates
  module Components
    module Forms
      class Select < Base
        include Capabilities::Configurable
        include Capabilities::Adoptable

        emits -> {
          label_tag(label_name, field_label)
          select_tag(resource_field_name, select_options, field_options)
        }

        def compile(*args)
          raise "Select requires a parent" if parent.nil?
          super(*args)
        end

        def resource_name
          parent.resource_name
        end

        def label_name
          "#{resource_name.singularize}_#{field_name}"
        end

        def field_label
          @options[:label] || field_name.titleize
        end

        def field_name
          @args.first.to_s
        end

        def resource_field_name
          "#{resource_name.singularize}[#{field_name}]"
        end

        def select_options
          options_specified = [Array, Hash].include?(@args.second.class)
          if options_specified
            options = @args.second
          else
            options = "@#{resource_name}.pluck(:#{field_name}).distinct"
          end

          if _belongs_to_association && !options_specified
            "{{options_from_collection_for_select(#{_related_collection}, :id, :name, @#{resource_name}.#{field_name})}}"
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

        private

          def _belongs_to_association
            begin
              reflection = resource_name.classify.constantize.reflect_on_association(field_name.to_sym)
              if reflection.macro.eql?(:belongs_to)
                return reflection
              end
            rescue
              nil
            end
          end

          def _related_collection
            if reflection = _belongs_to_association
              "#{reflection.klass}.all.select(:id, :name).order(:name)"
            end
          end
      end
    end
  end
end