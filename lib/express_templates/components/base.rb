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

      def self.builder_method_and_class(method_name, klass)
        Arbre::Element::BuilderMethods.class_eval <<-EOF, __FILE__, __LINE__
          def #{method_name}(*args, &block)
            insert_tag ::#{klass.name}, *args, &block
          end
        EOF
        # puts "added #{method_name} -> #{klass.name}"
      end

      def self.emits(proc = nil, &block)
        define_method(:build, &(proc || block))
      end

      def build(*args, block)
        raise "#build method must be overridden"
      end


      def self.inherited(subclass)
        builder_method_and_class subclass.to_s.demodulize.underscore, subclass
      end

      def indent_level
        parent.try(:indent_level) || 0
      end

      def to_s
        content.html_safe
      end

      def tag_name
        nil
      end

      def opening_tag
        ''
      end

      def closing_tag
        ''
      end

    end
  end
end
