module ExpressTemplates
  module Components
    #
    # Create an html <tt>form</tt> for a model object.
    #
    # Example:
    #
    # ```ruby
    # form_for(:people) do |t|
    #   t.text_field  :name
    #   t.email_field :email
    #   t.phone_field :phone
    # end
    # ```
    #
    class FormFor < Base
      include Capabilities::Configurable
      include Capabilities::Building

      def initialize(*args)
        super(*args)
        _process_args!(args) # from Configurable
        yield(self) if block_given?
      end

      attr :text_fields

      def text_field(name, options = {})
        @text_fields ||= []
        @text_fields << Field.new(name, options)
      end

      emits -> {
        form(action: "/#{my[:id].to_s}") {
          text_fields.each do |text_field|
            div.input.active {
              label_tag(text_field.name, text_field.label, class: 'string')
              text_field_tag(text_field.name, class: 'string')
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
        attr :name, :options, :label
        def initialize(name, options = {})
          @name = name
          @options = options
          @label = options[:label]
        end
      end
    end
  end
end
