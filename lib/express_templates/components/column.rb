module ExpressTemplates
  module Components
    class Column < Container
      include Capabilities::Configurable

      emits {
        div.column(my[:id]) {
          _yield
        }
      }
    end
  end
end
