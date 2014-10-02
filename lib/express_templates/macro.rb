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
      end
  end
end