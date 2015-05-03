module ExpressTemplates
  module Components
    module Forms
      class Submit < FormComponent

        emits -> {
          div(class: field_wrapper_class) {
            submit_tag(value)
          }
        }

        def value
          @args.first
        end
      end
    end
  end
end