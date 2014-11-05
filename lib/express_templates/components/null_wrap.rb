module ExpressTemplates
  module Components
    class NullWrap < Components::Container
      def compile
        compile_children
      end
    end
  end
end
