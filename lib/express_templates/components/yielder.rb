module ExpressTemplates
  module Components
    class Yielder
      def initialize(*args)
        @arg = args.first
      end

      def compile
        if @arg
          "yield(#{@arg.inspect})" # usually a symbol but may be string
        else
          "yield"
        end
      end

      def to_template
        compile
      end
    end
  end
end