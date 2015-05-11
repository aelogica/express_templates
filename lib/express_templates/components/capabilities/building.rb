module ExpressTemplates
  module Components
    module Capabilities
      module Building
        # commented this out because it's intercepting calls to rails helpers
        # TODO: fix this... I think the whole buiding approach is broken.
        #       this class is empty and should probably go away.
        # def method_missing(name, *args)
        #   raise "#{self.class.to_s} has no method '#{name}'"
        # end
      end
    end
  end
end
