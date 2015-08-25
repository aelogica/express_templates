module ExpressTemplates
  module Components
    module Capabilities

      module Resourceful

        def self.included(base)
          base.class_eval do
            has_argument :id, "The name of the collection", type: :symbol, optional: false
            has_option :collection, 'Provide an explicit collection as a resource.'
            has_option :collection_path, 'Provide an explicit path for the collection resource.', type: [:string, :proc]
            has_option :resource_class, 'Overrides namespaced resource_class for using resources from a different module or namespace.'
            has_option :resource_path, 'Overides the resource path which is otherwise inferred from the class name.', type: [:string, :proc]
            has_option :path_prefix, 'Rarely used.  Override inferred path_prefix for path helpers.'
            # note there is some duplication here.
            # resource_path can be specified as a proc which can specify a namespace
            # TODO: investigate which approach is better and deprecate if desirable
            has_option :namespace, 'Rarely used.  Overrides inferred namespace for resources.'
          end
        end

        def namespace
          config[:namespace] || infer_namespace
        end

        def path_prefix
          config[:path_prefix] || infer_path_prefix
        end

        def resource_class
          resource_class = config[:resource_class] || _namespaced_resource_class
          resource_class.constantize
        end

        private

        def _namespaced_resource_class
          if namespace
            "#{namespace}/#{resource_name}".classify
          else
            resource_name.classify
          end
        end

        def template_virtual_path
          begin
            super
          rescue
            nil
          end
        end

        def infer_namespace
          if template_virtual_path
            path_parts = template_virtual_path.split('/')

            case
            when path_parts.size == 4
              path_parts.first
            when path_parts.size == 3
              mod = path_parts.first.classify.constantize
              if mod.const_defined?(:Engine)
                path_parts.first
              else
                nil
              end
            else
              nil
            end
          else
            nil
          end
        end

        def infer_path_prefix
          if template_virtual_path
            path_parts = template_virtual_path.split('/')

            case
            when path_parts.size == 4
              path_parts[1]
            when path_parts.size == 3
              mod = path_parts.first.classify.constantize
              if mod.const_defined?(:Engine)
                nil
              else
                path_parts.first
              end
            else
              nil
            end
          else
            nil
          end
        end

        # TODO: this can now be inferred from the template.virtual_path
        # if not supplied...
        def resource_name
          config[:id].to_s.singularize
        end

        def collection_member_name
          resource_name
        end

        def collection_name
          collection_member_name.pluralize
        end

        def collection_var
          "@#{collection_name}".to_sym
        end

        def collection
          if config[:collection]
            if config[:collection].respond_to?(:call)
              config[:collection].call()
            else
              config[:collection]
            end
          else
            helpers.collection
          end
        end

        def collection_path
          if config[:collection_path]
            if config[:collection_path].respond_to?(:call)
              config[:collection_path].call()
            else
              config[:collection_path]
            end
          else
            if helpers.respond_to?(:collection_path)
              helpers.collection_path
            else
              helpers.instance_eval collection_path_helper
            end
          end
        end

        def collection_path_helper
          if path_namespace
            "#{path_namespace}.#{collection_name_with_prefix}_path"
          else
            "#{collection_name_with_prefix}_path"
          end
        end

        def collection_name_with_prefix
          if path_prefix
            "#{path_prefix}_#{collection_name}"
          else
            collection_name
          end
        end

        def resource_path_helper
          if path_namespace
            "#{path_namespace}.#{resource_name_with_path_prefix}_path"
          else
            "#{resource_name_with_path_prefix}_path"
          end
        end

        def path_namespace
          resource_class_name = resource.class.to_s
          resource_class_name.match(/::/) ?
            resource_class_name.split("::").first.try(:underscore) : nil
        end

        # accepts boolean to indicate whether to use an ivar or not
        # and also may accept a resource on which we call to_param
        def resource_path(ivar_or_resource = nil)
          if config[:resource_path]
            if config[:resource_path].respond_to?(:call) &&
              ivar_or_resource.respond_to?(:to_param) &&
              ![true, false].include?(ivar_or_resource)
              config[:resource_path].call(ivar_or_resource)
            else
              config[:resource_path]
            end
          else
            if helpers.respond_to?(:resource_path) &&
               helpers.resource.to_param.present? # skip on nil resource
              helpers.resource_path
            else
              if ivar_or_resource.respond_to?(:to_param) &&
                ![true, false].include?(ivar_or_resource)
                helpers.instance_eval("#{resource_path_helper}('#{ivar_or_resource.to_param}')")
              else
                helpers.instance_eval("#{resource_path_helper}(#{ivar_or_resource ? '@' : ''}#{resource_name})")
              end
            end
          end
        end

        def resource_name_with_path_prefix
          if path_prefix
            "#{path_prefix}_#{resource_name}"
          else
            resource_name
          end
        end

        def resource_attributes
          resource_class.columns
        end

        def resource
          self.send(resource_name)
        end
      end
    end
  end
end
