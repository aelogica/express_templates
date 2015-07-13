module ExpressTemplates
  module Components
    class Configurable < Base

      def self.emits(proc = nil, &block)
        define_method(:markup, &(proc || block))
      end

      def build(*args, &block)
        _process_args!(args)
        if method(:markup).arity > 0
          markup(block)
        else
          markup(&block)
        end
      end

      def config
        @config ||= {}
      end

      alias :my :config


      protected

        def _process_args!(args)
          if args.first.kind_of?(Symbol)
            config.merge!(id: args.shift)
            attributes[:id] = config[:id]
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