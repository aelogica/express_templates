module Gara
  module Components
    class Yielder
      def initialize(*args)
        @arg = args.first
      end

      def compile
        if @arg
          "yield(#{@arg})"
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