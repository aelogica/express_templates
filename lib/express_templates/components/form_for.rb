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

      def field(name, options = {})
        @fields ||= []
        @fields << Field.new(name, options)
      end

      emits -> {
        form(action: "/#{my[:id].to_s}") {

        }
      }

      # <form action='/posts'></form>

      def wrap_for_stack_trace(body)
        "ExpressTemplates::Components::FormFor.render_in(self) {\n#{body}\n}"
      end

      def compile
        wrap_for_stack_trace(lookup(:markup))
      end

      class Field
        attr :name, :options

        def initialize(name, options = {})
          @name = name
          @options = options
        end
      end
    end
  end
end
