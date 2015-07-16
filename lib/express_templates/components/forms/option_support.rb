module ExpressTemplates
  module Components
    module Forms
      # Provides a form component with knowledge of any association
      # on the field and an means of loading the collection for supplying
      # options to the user.
      module OptionSupport

        def has_many_through_association
          reflection = resource_class.reflect_on_association(field_name.to_sym)
          return reflection if reflection && reflection.macro.eql?(:has_many) && reflection.options.keys.include?(:through)
        end

        # Reflect on any association and return it if the association type
        # is :belongs_to.  Returns false if the association is not :belongs_to.
        # Returns nil if there was a problem reflecting.
        def belongs_to_association
          # assumes the belongs_to association uses <name>_id
          reflection = resource_class.reflect_on_association(field_name.gsub(/_id$/, '').to_sym)
          if reflection && reflection.macro.eql?(:belongs_to)
            return reflection
          end
        end

        # Provide ActiveRecord code to load the associated collection as
        # options for display.
        def related_collection
          reflection = belongs_to_association || has_many_through_association
          if reflection && !reflection.polymorphic?
            if cols.detect {|column| column.name.eql?('name') }
              reflection.klass.select(option_value_method.to_sym, option_name_method.to_sym).order(option_name_method.to_sym)
            else
              reflection.klass.all.sort_by(&option_name_method.to_sym)
            end
          end
        end

        protected

          def option_value_method
            :id
          end

          def cols
            @cols ||= (belongs_to_association||has_many_through_association).klass.columns
          end

          def option_name_method
            @option_name_method ||=
              if cols.detect {|column| column.name.eql?('name') } ||
                 resource_class.instance_methods.include?(:name)
                :name
              else
                if string_col = cols.detect {|column| column.type.eql?(:string) }
                  string_col.name.to_sym
                else
                  :id
                end
              end
          end

      end
    end
  end
end
