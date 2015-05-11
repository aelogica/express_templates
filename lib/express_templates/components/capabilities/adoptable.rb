module ExpressTemplates
  module Components
    module Capabilities
      module Adoptable
        # Adoptable adds the capability for a child to refer
        # to its parent.  This is used by more complex
        # components which are intended to work together
        # such as form components where form elements may need
        # to use information known only to the parent.

        def self.included(base)
          base.class_eval do
            attr_accessor :parent
          end
        end

      end
    end
  end
end