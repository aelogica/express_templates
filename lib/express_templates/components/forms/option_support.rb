module ExpressTemplates
  module Components
    module Forms
      # Provides a form component with knowledge of any association
      # on the field and an means of loading the collection for supplying
      # options to the user.
      module OptionSupport
        # Reflect on any association and return it if the association type
        # is :belongs_to.  Returns false if the association is not :belongs_to.
        # Returns nil if there was a problem reflecting.
        def belongs_to_association
          begin
            reflection = resource_name.classify.constantize.reflect_on_association(field_name.to_sym)
            if reflection.macro.eql?(:belongs_to)
              return reflection
            end
          rescue
            nil
          end
        end

        # Provide ActiveRecord code to load the associated collection as
        # options for display.
        def related_collection
          if reflection = belongs_to_association
            "#{reflection.klass}.all.select(:#{option_value_method}, :#{option_name_method}).order(:name)"
          end
        end

        protected

          def option_value_method
            :id
          end

          def option_name_method
            :name
          end

      end
    end
  end
end
