module ExpressTemplates
  module Components
    module Forms
      class Submit < Base
        include Capabilities::Configurable
        include Capabilities::Adoptable

        emits -> {
          submit_tag(my[:id])
        }
      end
    end
  end
end