module ExpressTemplates
  module Components
    module Capabilities
      module Iterating
        def self.included(base)
          base.class_eval do
            extend ClassMethods
          end
        end

        module ClassMethods
          # takes an :@variable assumed to be available in context
          # and iterates rendering the markup fragment specified by the emit: option
          # defaults to the fragment labeled :markup
          def for_each(iterator, as: :item, emit: :markup)
            if iterator.kind_of?(Symbol)
              var_name = iterator.to_s.gsub(/^@/,'').singularize.to_sym
            else
              var_name = as
            end
            using_logic do |component|
              collection = if iterator.kind_of?(Proc)
                instance_exec(&iterator)
              else
                eval(iterator.to_s)
              end
              collection.map do |item|
                b = binding
                b.local_variable_set(var_name, item)
                b.eval(component[emit], __FILE__)
              end.join
            end
          end
        end
      end
    end
  end
end
