module ExpressTemplates
  module Components
    # Provide hidden fields such as the authenticity token
    # and the utf8 enforcer tag as well as a method tag as
    # would be provided by Rails' form helpers.
    #
    # An optional method may be speficied.  Defaults to 'post'.
    class FormRailsSupport < Base
      include Capabilities::Configurable
      emits {
        div(style: 'display:none') {
          utf8_enforcer_tag
          method_tag(my[:id] || :post)
          token_tag
        }
      }
    end
  end
end
