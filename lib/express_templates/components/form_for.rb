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

      %w(email phone text password color date datetime 
        datetime_local file hidden month number range
        search telephone time url week).each do |type|
        define_method("#{type}_field") do |name, options={}|
          @fields ||= []
          @fields << Field.new(name, options, type.to_sym)
        end
      end

      emits -> {
        resource_name = my[:id].to_s
        form(action: %Q(/#{resource_name.pluralize})) {
          fields.each do |field|
            field_name = field.name
            field_type = field.type.to_s

            div.input.string {
              label_tag(field_name, field.label, class: 'string')
              args = [field_name, "{{@#{resource_name.singularize}.#{field_name}}}", class: 'string']
              self.send("#{field_type}_field_tag".to_sym, *args)
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
