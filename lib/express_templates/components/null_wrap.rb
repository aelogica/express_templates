module ExpressTemplates
  module Components
    class NullWrap < Components::Base
      def initialize(*args)
        @already_compiled_stuff = args.shift
        super(*args)
      end

      def compile
        @already_compiled_stuff
      end
    end
  end
end
