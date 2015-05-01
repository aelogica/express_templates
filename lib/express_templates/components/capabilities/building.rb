module ExpressTemplates
  module Components
    module Capabilities
      module Building
        def method_missing(name, *args)
          raise "#{self.class.to_s} has no method '#{name}'"
        end
      end
    end
  end
end
