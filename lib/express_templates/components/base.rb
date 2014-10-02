module ExpressTemplates
  module Components

    class Base

      def self.inherited(klass)
        ExpressTemplates::Expander.register_macros_for klass
      end

      # should be moved into a module shared with Tag
      def self.macro_name
        to_s.split('::').last.underscore
      end

      def self.emits(*args)
        if args.first.respond_to? :call
          _store :markup, _compile(args.first)
        else
          args.first.to_a.each do |name, block|
            raise ArgumentError unless name.is_a?(Symbol) and block.is_a?(Proc)
            _store(name, _compile(block))
          end
        end
      end

      def self.has_markup(&block)
        emits(markup: block)
      end

      def self.using_logic(&block)
        @control_flow = block
      end

      # takes an :@variable assumed to be available in context
      # and iterates rendering the markup fragment specified by the emit: option
      # defaults to the fragment labeled :markup
      def self.for_each(iterator, as: :item, emit: :markup)
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

      def self.wrap_with(fragment)
        prior_logic = @control_flow
        using_logic do |component|
          component._wrap_using(fragment, self, &prior_logic)
        end
      end

      def self.content_for(label, &block)
        _lookup(label)
      end

      def self.insert(label)
        eval(_lookup(label))
      end

      def self._wrap_using(label, context=nil, &to_be_wrapped)
        body = ''
        if to_be_wrapped && context
          body = render(context, &to_be_wrapped)
        end
        insert(label).gsub(/\{\{_yield\}\}/, body)
      end


      def self._yield(*args)
        "{{_yield}}"
      end

      def compile
        if _provides_logic?
          "#{self.class.to_s}.render(self)"
        else
          self.class._lookup(:markup)
        end
      end

      def self.render(context, fragment=nil, &block)
        if fragment
          context.instance_eval(_lookup(fragment))
        else
          flow = block || @control_flow
          context.instance_exec(self, &flow)
        end
      end

      private 

        # change to use ExpressTemplates.compile?
        def self._compile(block)
          special_handlers = {insert: self, _yield: self}

          ExpressTemplates::Expander.new(nil, special_handlers).expand(&block).map(&:compile).join("+")
        end

        def _provides_logic?
          !!self.class._control_flow
        end

        def self._control_flow
          @control_flow
        end

        def self._store(name, ruby_string)
          @compiled_template_code ||= Hash.new
          @compiled_template_code[name] = ruby_string
        end

        def self._lookup(name)
          @compiled_template_code ||= Hash.new
          @compiled_template_code[name] or raise "no compiled template code for: #{name}"
        end

    end

    class << Base
      alias_method :renders, :emits
      alias_method :fragments, :emits
      alias_method :[], :_lookup
    end

  end
end
