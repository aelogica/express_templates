module ExpressTemplates
  module Components
    #
    # Create an html <tt>form</tt> for a model object.
    #
    # Example:
    #
    # ````ruby
    # form_for(:people) do |f|
    #   f.text_field  :name
    #   f.email_field :email
    #   f.phone_field :phone, wrapper_class: 'field phone'
    #   f.submit 'Save'
    # end
    # ````
    #
    class FormFor < Base
      include Capabilities::Configurable
      include Capabilities::Building


      def initialize(*args)
        # TODO: need a better way to select the form options
        @form_options = args.select { |x| x.is_a?(Hash) }
        super(*args)
        _process_args!(args) # from Configurable
        yield(self) if block_given?
      end

      attr :fields

      %w(email phone text password color date datetime
        datetime_local hidden number range
        search telephone time url week).each do |type|
        define_method("#{type}_field") do |name, options={}|
          @fields ||= []
          @fields << Field.new(name, options, type.to_sym)
        end
      end

      def select(name, select_options, options = {})
        @fields ||= []
        @fields << Select.new(name, options.merge!(select_options: select_options))
      end

      def radio(name, collection, value_method, text_method, options = {})
        @fields ||= []
        @fields << Radio.new(name, options.merge!(collection: collection, value_method: value_method, text_method: text_method))
      end

      def checkbox(name, collection, value_method, text_method, options = {})
        @fields ||= []
        @fields << Checkbox.new(name, options.merge!(collection: collection, value_method: value_method, text_method: text_method))
      end

      def submit(name = 'Submit Changes', options = {})
        @fields ||=[]
        @fields << Field.new(name, options, :submit)
      end

      emits -> {
        resource_name = my[:id].to_s
        form_options = @form_options.first
        form_method = form_options.delete :method

        form_method = if form_method == :put
                        :patch
                      else
                        form_options[:method]
                      end

        form_action  = if form_method == :patch
                       %Q(/#{resource_name.pluralize}/{{@#{resource_name}.id}})
                       else
                       %Q(/#{resource_name.pluralize})
                     end

        form_args = {action: form_action, method: :post}
        form_args.merge!(form_options) unless form_options.nil?

        form(form_args) {
          form_rails_support form_method
          fields.each do |field|
            field_name = field.name
            field_type = field.type.to_s
            resource_field_name = "#{resource_name.singularize}[#{field_name}]"

            div(class: field.wrapper_class) {
              if field_type == 'select'
                  label_tag(field_name, field.label)
                  select_tag(resource_field_name, field.options_html, field.options)
              elsif field_type == 'radio'
                collection_radio_buttons(my[:id], field_name, field.collection,
                                         field.value_method, field.text_method, field.options) do |b|
                  b.label(class: 'radio') { b.radio_button + b.text }
                end
              elsif field_type == 'checkbox'
                collection_check_boxes(my[:id], field_name, field.collection,
                                       field.value_method, field.text_method, field.options) do |b|
                  b.label(class: 'checkbox') { b.check_box + b.text }
                end
              elsif field_type == 'submit'
                submit_tag(field_name, field.options)
              else
                label_tag(field_name, field.label) unless field_type == 'hidden'
                args = [resource_field_name, "{{@#{resource_name.singularize}.#{field_name}}}", field.options]
                self.send("#{field_type}_field_tag".to_sym, *args)
              end
            }
          end
        }
      }

      def wrap_for_stack_trace(body)
        "ExpressTemplates::Components::FormFor.render_in(self) {\n#{body}\n}"
      end

      def compile
        wrap_for_stack_trace(lookup(:markup))
      end

      class Field
        attr :name, :options, :label, :type, :wrapper_class
        def initialize(name, options = {}, type=:text)
          @name = name
          @options = options
          @label = options[:label]
          @wrapper_class = @options.delete(:wrapper_class)
          @type = type
        end
      end

      class Radio < Field
        attr :collection, :value_method, :text_method
        def initialize(name, options = {})
          @collection = options.delete :collection
          @value_method = options.delete :value_method
          @text_method = options.delete :text_method
          super(name, options, :radio)
        end
      end

      class Checkbox < Radio
        def initialize(name, options = {})
          super(name, options)
          @type = :checkbox
        end
      end

      class Select < Field
        attr :choices
        def initialize(name, options = {})
          @choices = options.delete :select_options
          @selected = options.delete :selected
          super(name, options, :select)
        end

        def options_html
          choice_string = ""
          if @choices.is_a?(String)
            choice_string = @choices
          else
            @choices.map do |choice|
              selected_string = (@selected != nil && choice == @selected) ? 'selected=selected' : nil
              choice_string << "<option #{selected_string}>#{choice}</option>"
            end
            "{{'#{choice_string}'.html_safe}}"
          end
        end
      end
    end
  end
end
