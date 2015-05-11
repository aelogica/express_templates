module ExpressTemplates
  module Components
    # Provide hidden fields such as the authenticity token
    # and the utf8 enforcer tag as well as a method tag as
    # would be provided by Rails' form helpers.
    #
    # An optional method may be speficied.  Defaults to 'post'.
    class FormRailsSupport < Base
      include Capabilities::Configurable
      emits -> {
        div(style: 'display:none') {
          utf8_enforcer_tag
          # NOTE: This should be moved into the forms module and made a FormComponent
          #       to have access to the resource_name as this code assumes existence of
          #       a resource method which may not exist
          method_tag(@config[:id] || "{{((resource.persisted? ? :put : :post) rescue :post)}}")
          token_tag
        }
      }
    end
  end
end
