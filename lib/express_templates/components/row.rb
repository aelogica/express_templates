module ExpressTemplates
  module Components
    # A Row is a Container implemented as a div with
    # a CSS class "row"
    #
    # An optional dom ID may be specified as a symbol.
    #
    # Example:
    #
    #     row(:main) {
    #       p "Some content"
    #     }
    #
    # This will render as:
    #
    #     <div id="main" class="row"><p>Some content</p></div>
    #
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
