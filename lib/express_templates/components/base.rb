module ExpressTemplates
  module Components

    module ClassMethods

      def inherited(klass)
        ExpressTemplates::Expander.register_macros_for klass
      end


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

      def using_logic(&block)
        @control_flow = block
      end

      # takes an :@variable assumed to be available in context
      # and iterates rendering the markup fragment specified by the emit: option
      # defaults to the fragment labeled :markup
      def for_each(iterator, as: :item, emit: :markup)
        if iterator.kind_of?(Symbol)
          var_name = iterator.to_s.gsub(/^@/,'').singularize.to_sym
        else
          var_name = as
        end
        using_logic do |component|
          collection = if iterator.kind_of?(Proc)
            instance_exec(&iterator)
          else
            eval(iterator.to_s)
          end
          collection.map do |item|
            b = binding
            b.local_variable_set(var_name, item)
            b.eval(component[emit], __FILE__)
          end.join
        end
      end

      def wrap_with(fragment)
        prior_logic = @control_flow
        using_logic do |component|
          component._wrap_using(fragment, self, &prior_logic)
        end
      end

      def insert(label)
        eval(_lookup(label))
      end

      def _wrap_using(label, context=nil, &to_be_wrapped)
        body = ''
        if to_be_wrapped && context
          body = render(context, &to_be_wrapped)
        end
        insert(label).gsub(/\{\{_yield\}\}/, body)
      end


      def _yield(*args)
        "{{_yield}}"
      end

      def render(context, fragment=nil, &block)
        if fragment
          context.instance_eval(_lookup(fragment))
        else
          flow = block || @control_flow
          context.instance_exec(self, &flow)
        end
      end

      def [](label)
        _lookup(label)
      end

      private 

        # change to use ExpressTemplates.compile?
        def _compile(block)
          special_handlers = {insert: self, _yield: self}

          ExpressTemplates::Expander.new(nil, special_handlers).expand(&block).map(&:compile).join("+")
        end

        def _control_flow
          @control_flow
        end

        def _store(name, ruby_string)
          @compiled_template_code ||= Hash.new
          @compiled_template_code[name] = ruby_string
        end

        def _lookup(name)
          @compiled_template_code ||= Hash.new
          @compiled_template_code[name] or raise "no compiled template code for: #{name}"
        end

    end

    module InstanceMethods
      def compile
        if _provides_logic?
          "#{self.class.to_s}.render(self)"
        else
          self.class[:markup]
        end
      end

      private

        def _provides_logic?
          !!self.class.send(:_control_flow)
        end

    end


    class Base
      include ExpressTemplates::Macro
      extend ClassMethods
      include InstanceMethods
    end

    class << Base
      alias_method :fragments, :emits
      alias_method :has_markup, :emits
    end


  end
end
