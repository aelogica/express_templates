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

      attr :fields

      def text_field(name, options = {})
        @fields ||= []
        @fields << Field.new(name, options)
      end

      def email_field(name, options = {})
        @fields ||= []
        @fields << Field.new(name, options, :email)
      end

      def phone_field(name, options = {})
        @fields ||= []
        @fields << Field.new(name, options, :phone)
      end

      emits -> {
        form(action: %Q(/#{my[:id].to_s.pluralize})) {
          fields.each do |field|
            div.input.string {
              label_tag(field.name, field.label, class: 'string')

              args = [field.name, "{{@#{my[:id].to_s.singularize}.#{field.name}}}", class: 'string']

              case field.type
              when :email
                email_field_tag(*args)
              when :phone
                phone_field_tag(*args)
              else
                text_field_tag(*args)
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
        attr :name, :options, :label, :type
        def initialize(name, options = {}, type=:text)
          @name = name
          @options = options
          @label = options[:label]
          @type = type
        end
      end
    end
  end
end
