module ExpressTemplates
  module Components
    class Base

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

      def self.for_each(iterator)
        using_logic {|component| eval(iterator.to_s).map { |item| eval(component[:markup]) }.join }
      end

      def insert(label)
        _lookup(label)
      end

      def compile
        if _provides_logic?
          "#{self.class.to_s}.render(self)"
        else
          self.class._lookup(:markup)
        end
      end

      def self.render(context)
        context.instance_exec(self, &@control_flow)
      end

      private 

        def self._compile(block)
          ExpressTemplates::Expander.new(nil).expand(&block).map(&:compile).join("+")
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

        def self.[](name)
          _lookup(name)
        end

        def _lookup(name)
          self.class._lookup(name)
        end
    end

    class << Base
      alias_method :renders, :emits
    end

  end
end
