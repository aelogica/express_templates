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
          if @args.first.is_a?(String)
            @args.first
          else
            'Save'
          end
        end

        def html_options
          @config
        end
      end
    end
  end
end
