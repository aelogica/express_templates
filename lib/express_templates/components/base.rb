capabilities = Dir.glob(File.join(File.dirname(__FILE__), 'capabilities', '*.rb'))
capabilities.each {|capability| require capability}

module ExpressTemplates
  # Components provide self-contained reusable view code meant to be shared
  # within a project or across many projects through a library of components
  #
  module Components

    # Components::Base is the base class for ExpressTemplates view components.
    #
    #
    class Base < Arbre::Component

      class_attribute :before_build_hooks
      self.before_build_hooks = []

      def self.builder_method_and_class(method_name, klass)
        Arbre::Element::BuilderMethods.class_eval <<-EOF, __FILE__, __LINE__
          def #{method_name}(*args, &block)
            insert_tag ::#{klass.name}, *args, &block
          end
        EOF
        # puts "added #{method_name} -> #{klass.name}"
      end

      def initialize(*)
        super
        _default_attributes.each do |name, value|
          set_attribute(name, value)
        end
        add_class _default_classes
      end

      def self.contains(proc = nil, &block)
        define_method(:_build_body, &(proc || block))
      end

      # Override the tag_name method for other than <div>
      def self.tag(tag)
        define_method(:tag_name) { tag }
      end

      # Provide default attributes for the enclosing tag
      # of the component
      def self.has_attributes(attribs)
        self._default_classes = attribs.delete(:class)
        _default_attributes.merge!(attribs)
      end

      def self.before_build(proc_or_symbol = nil, exclusive: false, &block)
        hook = (proc_or_symbol || block)
        unless hook.kind_of?(Symbol) or hook.respond_to?(:call)
          raise "before_build requires symbol (method_name), proc or block"
        end
        if exclusive
          self.before_build_hooks = [hook]
        else
          self.before_build_hooks += [hook]
        end
      end

      def build(*args, &block)
        _extract_class!(args)
        _run_before_build_hooks
        super(*args) {
          _build_body(&block) if respond_to?(:_build_body)
        }
      end

      def resource
        helpers.resource
      end

      def self.inherited(subclass)
        builder_method_and_class subclass.builder_method_name, subclass
      end

      def self.builder_method_name
        to_s.demodulize.underscore
      end

      def builder_method_name
        self.class.builder_method_name
      end

      def self.descendants
        ObjectSpace.each_object(Class).select { |klass| klass < self }
      end

      protected
        def default_class_name
          self.class.name.demodulize.underscore.dasherize
        end


      private
        def _run_before_build_hooks
          before_build_hooks.each do |hook|
            if hook.kind_of?(Symbol)
              self.send(hook)
            else
              instance_exec &hook
            end
          end
        end
        def _extract_class!(args)
          add_class args.last.delete(:class) if args.last.try(:kind_of?, Hash)
        end
        def _default_attributes
          self.class._default_attributes
        end
        def self._default_attributes
          @default_attributes ||= {}
        end
        def _default_classes
          self.class._default_classes
        end
        def self._default_classes
          @default_classes ||= ''
        end
        def self._default_classes=(classes)
          @default_classes = classes
        end

    end
  end
end
