module ExpressTemplates
  module Components
    class Configurable < Base

      def self.emits(*args, &block)
        warn ".emits is deprecrated"
        self.contains(*args, &block)
      end

      def build(*args, &block)
        _extract_supported_options!(args)
        super(*args, &block)
      end

      def config
        @config ||= {}
      end

      def self.has_option(name, description, option_options = {})
        raise "name must be a symbol" unless name.kind_of?(Symbol)
        _check_valid_keys(option_options)
        _supported_options[name] = {description: description}.merge(option_options)
      end

      protected

        def self._check_valid_keys(options)
          recognized_keys = [:required, :type, :default]
          unrecognized_keys = options.keys - recognized_keys
          if unrecognized_keys.any?
            raise "unrecognized options for #{self.class}: #{unrecognized_keys.inspect}"
          end
        end

        def _supported_options
          self.class._supported_options
        end
        def self._supported_options
          @supported_options ||= {}
        end

        def _required_options
          _supported_options.select {|k,v| v[:required] }
        end

        def _check_required_options(supplied)
          missing = _required_options.keys - supplied.keys
          if missing.any?
            raise "#{self.class} missing required option(s): #{missing}"
          end
        end

        def _extract_supported_options!(args)
          if args.first.kind_of?(Symbol)
            config.merge!(id: args.shift)
            attributes[:id] = config[:id]
          end

          builder_options = args.last.try(:kind_of?, Hash) ? args.last : {}

          _check_required_options(builder_options)

          builder_options.each do |key, value|
            if _supported_options.keys.include?(key)
              config[key] = builder_options.delete(key)
            end
          end
        end

    end
  end
end