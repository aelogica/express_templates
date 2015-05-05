module ExpressTemplates
  module Components
    module Forms
      class Submit < FormComponent

        emits -> {
          div(class: field_wrapper_class) {
            submit_tag(value, html_options)
          }
        }

        def value
          @args.first
        end

        def html_options
          @args.second
        end
      end
    end
  end
end
