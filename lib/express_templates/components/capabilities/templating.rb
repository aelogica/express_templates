module ExpressTemplates
  module Components
    module Capabilities

      # The Templating capability module provides Components with the ability
      # to store, reference and compile template fragments.
      #
      # It extends the including class with Templating::ClassMethods.
      #
      # It also provides helpers which are snippets of code in the form of
      # lambdas that may be evaluated in the view context.
      #
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
              fragment = (args.first||template_code)
              raise "must use stabby lambda" unless fragment.lambda?
              _store :markup, fragment# default fragment is named :markup
            else
              args.first.to_a.each do |name, block|
                raise ArgumentError unless name.is_a?(Symbol) and block.is_a?(Proc)
                _store(name, block)
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
            _define_helper_methods name
          end

          def special_handlers
            {insert: self, _yield: self}.merge(Hash[*(_helpers.keys.map {|k| [k, self] }.flatten)])
          end

          protected

            # Stores a fragment for use during compilation and rendering
            # of a component.
            def _store(name, fragment)
              @fragments ||= Hash.new
              @fragments[name] = fragment
            end

            # Looks up a template fragment for this component and returns
            # compiled template code.
            #
            # If the template fragment is not already compiled, it compiles it
            # with the supplied options as locals.  Locals may be used within
            # the template during expansion.
            #
            # Returns a string containing ruby code which evaluates to markup.
            def _lookup(name, options = {})
              @fragments ||= Hash.new
              @fragments[name] or binding.pry #raise "no template fragment supplied for: #{name}"
            end

          private


            def _helpers
              @helpers ||= Hash.new
            end

            def _define_helper_methods(name)
              method_definition= <<-RUBY
                class << self

                  # called during expansion
                  define_method(:#{name}) do |*args|
                    helper_args = %w(self)
                    helper_args += args.map(&:inspect)
                    '\#\{#{self.to_s}._#{name}('+_interpolate(helper_args).join(', ')+')\}'
                  end

                  # called during rendering in view context
                  define_method(:_#{name}) do |context, *args|
                    begin
                      helper_proc = _helpers[:#{name}]
                      helper_args = args.take(helper_proc.arity)
                      context.instance_exec *helper_args, &helper_proc
                    rescue => e
                      raise "#{name} raised: \#\{e.to_s\}"
                    end.to_s
                  end
                end
              RUBY
              eval(method_definition)
            end

            def _interpolate(args)
              args.map do |arg|
                if arg.kind_of?(String) && match = arg.match(/"\{\{(.*)\}\}"/)
                  match[1]
                else
                  arg
                end
              end
            end

        end

        module InstanceMethods

          def lookup(fragment_name, options={})
            fragment = self.class[fragment_name]
            if fragment.kind_of?(Proc)
              _compile_fragment(fragment, options)
            else
              fragment
            end
          end

          # Expands and compiles the supplied block representing a
          # template fragment.
          #
          # Any supplied options are passed as locals for use during expansion.
          #
          # Returns a string containing ruby code which evaluates to markup.
          def _compile_fragment(block, options = {})
            initialize_expander(nil, self.class.special_handlers, options)
            expand(&block).map(&:compile).join("+").gsub('"+"', '')
          end


        end


      end
    end
  end
end