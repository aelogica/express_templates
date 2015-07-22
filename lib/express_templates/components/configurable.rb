module ExpressTemplates
  module Components
    # Configurable components support configuration options supplied to the
    # builder method.  Supported options must be declared.  All other options
    # are passed along and converted to html attributes.
    #
    # Example:
    #
    # ```ruby
    #
    # class Pane < ExpressTemplates::Components::Configurable
    #   has_option :title, "Displayed in the title area", required: true
    #   has_option :status, "Displayed in the status area"
    # end
    #
    # # Usage:
    #
    # pane(title: "People", status: "#{people.count} people")
    #
    # ```ruby
    #
    # Options specified as required must be supplied.
    #
    # Default values may be supplied for options with a default: keyword.
    #
    # Options may be passed as html attributes with attribute: true
    #
    class Configurable < Base

      def self.emits(*args, &block)
        warn ".emits is deprecrated"
        self.contains(*args, &block)
      end

      def build(*args, &block)
        _process_builder_args!(args)
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
          recognized_keys = [:required, :type, :default, :attribute]
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
          _supported_options.select {|k,v| v[:required] unless v[:default] }
        end

        def _default_options
          _supported_options.select {|k,v| v[:default] }
        end

        def _check_required_options(supplied)
          missing = _required_options.keys - supplied.keys
          if missing.any?
            raise "#{self.class} missing required option(s): #{missing}"
          end
        end

        def _set_defaults
          _default_options.each do |key, value|
            if !!value[:attribute]
              set_attribute key, value[:default]
            else
              config[key] ||= value[:default]
            end
          end
        end

        def _set_id(args)
          if args.first.kind_of?(Symbol)
            config.merge!(id: args.shift)
            attributes[:id] = config[:id]
          end
        end

        def _extract_supported_options!(builder_options)
          builder_options.each do |key, value|
            if _supported_options.keys.include?(key)
              unless _supported_options[key][:attribute]
                config[key] = builder_options.delete(key)
              end
            end
          end
        end

        def _process_builder_args!(args)
          _set_id(args)
          builder_options = args.last.try(:kind_of?, Hash) ? args.last : {}
          _check_required_options(builder_options)
          _extract_supported_options!(builder_options)
          _set_defaults
        end

    end
  end
end