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
              super
            end
          end
        end

        module ClassMethods
          # Override Rendering::ClassMethods.render to process options
          def render(context, fragment=nil, &block)
            raise "not implemented yet"
          end


          protected

            # Override to delay compilation
            def _compile(block)
              block
            end

        end

        module InstanceMethods

          def config
            @config
          end

          alias :my :config

          def [] key
            config[key]
          end

          def compile
            if _provides_logic?
              "#{self.class.to_s}.render(self, #{options.inspect})"
            else
              _compile_with_options self.class[:markup]
            end
          end

          private

            def _compile_with_options(block)
              special_handlers = self.class.special_handlers
              expander = ExpressTemplates::Expander.new(nil, special_handlers, my: self)
              expander.expand(&block).map(&:compile).join("+")
            end

            def _process_args!(args)
              if args.first.kind_of?(Symbol)
                config.merge!(id: args.shift)
              end
              args.each do |arg|
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
