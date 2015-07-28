module ExpressTemplates
  module Components
    module Capabilities

      module Resourceful

        def self.included(base)
          base.class_eval do
            has_argument :id, "The name of the collection", type: :symbol, optional: false
            has_option :collection, 'Provide an explicit collection as a resource.'
            has_option :collection_path, 'Provide an explicit path for the collection resource.'
            has_option :resource_class, 'Overrides namespaced resource_class for using resources from a different module or namespace.'
            has_option :resource_path, 'Overides the resource path which is otherwise inferred from the class name.'
            has_option :path_prefix, 'Rarely used.  Override inferred path_prefix for path helpers.'
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
            config[:collection_path]
          else
            #super
            helpers.instance_eval "#{collection_name_with_prefix}_path"
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
          "#{resource_name_with_path_prefix}_path"
        end

        def resource_path(ivar=false)
          if config[:resource_path]
            config[:resource_path]
          else
            # super
            helpers.instance_eval("#{resource_path_helper}(#{ivar ? '@' : ''}#{resource_name})")
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
      end
    end
  end
end
