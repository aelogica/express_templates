module ExpressTemplates
  module Components
    class Row < Container
      include Capabilities::Configurable

      emits {
        div.row(my[:id]) {
          _yield
        }
      }
    end
  end
end
