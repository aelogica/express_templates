module ExpressTemplates
  module Components
    module Forms
      module FormSupport

        def form_action
          @config[:action] || "{{@#{resource_name}.try(:persisted?) ? #{resource_path(ivar: true)} : #{collection_path}}}"
        end

      end
    end
  end
end
