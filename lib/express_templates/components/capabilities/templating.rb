module ExpressTemplates
  module Components
    module Capabilities
      module Templating
        def self.included(base)
          base.class_eval do
            extend ClassMethods
            include InstanceMethods
          end
          class << base
            alias_method :fragments, :emits
            alias_method :has_markup, :emits
          end
        end

        module ClassMethods

          # Store fragments of ExpressTemplate style markup for use in
          # generating the HTML representation of a component.
          #
          # For example in your class, simply place the following:
          #
          #     class MyComponent < ET::Components::Base
          #       emits {
          #         ul {
          #           li "one"
          #           li "two"
          #           li "three"
          #         }
          #       }
          #
          #     end
          #
          # By default this template code is stored under the label :markup
          # 
          # You may specify several fragments with a hash containing lambdas:
          #
          #       emits body:     -> { li "item" },
          #             wrapper:  -> { ul { _yield } }
          #
          # This method is aliased as <tt>fragments</tt> and <tt>has_markup</tt>
          # 
          def emits(*args, &template_code)
            if args.first.respond_to?(:call) or template_code
              _store :markup, _compile(args.first||template_code) # default fragment is named :markup
            else
              args.first.to_a.each do |name, block|
                raise ArgumentError unless name.is_a?(Symbol) and block.is_a?(Proc)
                _store(name, _compile(block))
              end
            end
          end

          def [](label)
            _lookup(label)
          end

          # Stores a block given for later evaluation in context.
          #
          # Example:
          #
          #       class TitleComponent < ECB
          #         helper :title_helper do
          #           @resource.name
          #         end
          #
          #         emits {
          #           h1 {
          #             title_helper
          #           }
          #         }
          #
          #       end
          #
          # In this example <tt>@resource.name</tt> is evaluated in the
          # provided context during page rendering and not during template
          # expansion or compilation.
          #
          # This is the recommended for encapsulation of "helper" type
          # functionality which is of concern only to the component and
          # used only in its own markup fragments.
          def helper(name, &block)
            _helpers[name] = block
            _define_helper_method name
          end

          def special_handlers
            {insert: self, _yield: self}.merge(Hash[*(_helpers.keys.map {|k| [k, self] }.flatten)])
          end

          protected

            def _store(name, ruby_string)
              @compiled_template_code ||= Hash.new
              @compiled_template_code[name] = ruby_string
            end

            def _lookup(name)
              @compiled_template_code ||= Hash.new
              @compiled_template_code[name] or raise "no compiled template code for: #{name}"
            end

            # change to use ExpressTemplates.compile?
            def _compile(block)
              ExpressTemplates::Expander.new(nil, special_handlers).expand(&block).map(&:compile).join("+")
            end


          private


            def _helpers
              @helpers ||= Hash.new
            end

            def _define_helper_method(name)
              method_definition= <<-RUBY
                class << self
                  define_method(:#{name}) do |context=nil|
                    begin
                      if context
                        context.instance_exec &_helpers[:#{name}]
                      else
                        %Q("+#{self.to_s}.#{name}(self)+")
                      end
                    rescue => e
                      raise "#{name} raised: \#\{e.to_s\}"
                    end.to_s
                  end
                end
              RUBY
              # binding.pry
              eval(method_definition)
            end


        end

        module InstanceMethods
        end

      end
    end
  end
end