module ExpressTemplates
  module Components
    module Forms
      class Submit < FormComponent

        def build(*args)
          div(class: field_wrapper_class) {
            if args.first.is_a?(String) or args.empty?
              submit_tag(args.first || 'Save', (args[1]||{}))
            else
              submit_tag 'Save', (args.first || {})
            end
          }
        end

        def value
          if @args.first.is_a?(String)
            @args.first
          else
            'Save'
          end
        end

      end
    end
  end
end
