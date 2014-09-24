module ExpressTemplates
  module Components
    class Base

      def self.emits(*args)
        args.first.to_a.each do |name, block|
          raise ArgumentError unless name.is_a?(Symbol) and block.is_a?(Proc)
          _store(name, ExpressTemplates::Expander.new(nil).expand(&block).map(&:compile).join("+"))
        end
      end

      def self.has_markup(&block)
        emits(markup: block)
      end

      def self.using_logic(&block)
        @control_flow = block
      end

      def insert(label)
        _lookup(label)
      end

      def compile
        if _control_flow
          "#{self.class.to_s}.control(self, '#{self.class._lookup(:markup)}')"
        else
          self.class._lookup(:markup)
        end
      end

      def self.control(context, markup)
        context.instance_exec(markup, &@control_flow)
      end

      private 

        def _control_flow
          self.class._control_flow
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

        def _lookup(name)
          self.class._lookup(name)
        end
    end
  end
end
