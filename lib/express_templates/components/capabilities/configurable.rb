module ExpressTemplates
  module Components
    module Capabilities

      # Configurable components accept options which they can use to alter
      # their markup each time they are invoked within a template.
      #
      # They do not compile their markup fragments at load time as simpler
      # components do for efficiency.  Rather they compile their fragments
      # when they are themselves undergoing compilation.  This facilitates
      # access to arguments which were passed to the component at initialization.
      #
      # For example, if we have a Row component that is Configurable:
      #
      #     row(:main)
      #
      # might process to:
      #
      #     <div id="main" class="row" />
      #

      module Configurable
        def self.included(base)
          base.class_eval do
            extend ClassMethods
            include InstanceMethods

            # Stores arguments for later processing, eg., compile time
            def initialize(*args)
              @args = args.dup
              @config = {}
              _process_args!(args)
              super(*args)
            end
          end
        end

        module ClassMethods

          protected

            # Override to delay compilation
            def _compile_fragment(block, options = {})
              if options.delete(:force_compile)
                super(block, options)
              else
                block
              end
            end

            def _lookup(name, options = {})
              super(name, options.merge(force_compile: true))
            end

        end

        module InstanceMethods

          def config
            @config
          end

          alias :my :config

          def expand_locals
            {my: config}
          end

          private

            def _process_args!(args)
              if args.first.kind_of?(Symbol)
                config.merge!(id: args.shift)
              end
              while arg = args.shift
                if arg.kind_of?(Hash)
                  config.merge!(arg)
                end
              end
            end
        end
      end
    end
  end
end
