module ExpressTemplates
  module Macro

      def self.included(base)
        base.class_eval do
          extend ClassMethods
          include InstanceMethods
        end
      end

      module ClassMethods
        def macro_name
          to_s.split('::').last.underscore
        end
      end
      module InstanceMethods
        def macro_name ; self.class.macro_name end

        def initialize(*children_or_options)
          @children = []
          @options = {}.with_indifferent_access
          # expander passes itself as last arg
          @expander = children_or_options.pop if children_or_options.last.kind_of?(ExpressTemplates::Expander)
          _process(*children_or_options)
        end

        private

          def _process(*children_or_options)
            children_or_options.each do |child_or_option|
              case
              when child_or_option.kind_of?(Hash)
                @options.merge!(child_or_option)
              when child_or_option.kind_of?(Symbol)
                @options.merge!(id: child_or_option.to_s)
              when child_or_option.nil?
              else
                @children << child_or_option
              end
            end
          end

      end
  end
end