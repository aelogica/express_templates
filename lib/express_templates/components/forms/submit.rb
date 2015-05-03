module ExpressTemplates
  module Components
    module Forms
      class Submit < Base
        include Capabilities::Configurable
        include Capabilities::Adoptable

        emits -> {
          submit_tag(value)
        }

        def value
          @args.first
        end
      end
    end
  end
end