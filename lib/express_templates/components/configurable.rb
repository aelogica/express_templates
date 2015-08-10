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

      class_attribute :supported_options
      self.supported_options = {}

      class_attribute :supported_arguments
      self.supported_arguments = {}

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

      def self.has_option(name, description, type: :string, required: nil, default: nil, attribute: nil, values: nil)
        raise "name must be a symbol" unless name.kind_of?(Symbol)
        option_definition = {description: description}
        option_definition.merge!(type: type, required: required, default: default, attribute: attribute, values: values)
        self.supported_options =
          self.supported_options.merge(name => option_definition)
      end

      def required_options
        supported_options.select {|k,v| v[:required] unless v[:default] }
      end

      def self.has_argument(name, description, as: nil, type: :string, default: nil, optional: false)
        raise "name must be a symbol" unless name.kind_of?(Symbol)
        argument_definition = {description: description, as: as, type: type, default: default, optional: optional}
        self.supported_arguments =
          self.supported_arguments.merge(name => argument_definition)
      end

      has_argument :id, "The id of the component.", type: :symbol, optional: true

      protected

        def _default_options
          supported_options.select {|k,v| v[:default] }
        end

        def _check_required_options(supplied)
          missing = required_options.keys - supplied.keys
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

        def _valid_types(definition)
          valid_type_names = if definition[:type].kind_of?(Symbol)
              [definition[:type]]
            elsif definition[:type].respond_to?(:keys)
              definition[:type].keys
            else
              definition[:type] || []
            end
          valid_type_names.map do |type_name|
            if type_name.eql?(:boolean)
              type_name
            else
              type_name.to_s.classify.constantize
            end
          end
        end

        def _is_valid?(value, definition)
          valid_types = _valid_types(definition)
          if valid_types.empty? && value.kind_of?(String)
            true
          elsif valid_types.include?(value.class)
            true
          elsif valid_types.include?(:boolean) &&
                [1, 0, true, false].include?(value)
            true
          else
            false
          end
        end

        def _optional_argument?(definition)
          definition[:default] || definition[:optional]
        end

        def _required_argument?(definition)
          !_optional_argument?(definition)
        end

        def _extract_supported_arguments!(args)
          supported_arguments.each do |key, definition|
            value = args.shift
            if value.nil? && _required_argument?(definition)
              raise "argument for #{key} not supplied"
            end
            unless _is_valid?(value, definition)
              if _required_argument?(definition)
                raise "argument for #{key} invalid (#{value.class}) '#{value.to_s}'; Allowable: #{_valid_types(definition).inspect}"
              else
                args.unshift value
                next
              end
            end
            config_key = definition[:as] || key
            config[config_key] = value || definition[:default]
          end
        end

        def _set_id_attribute
          attributes[:id] = config[:id]
        end

        def _extract_supported_options!(builder_options)
          builder_options.each do |key, value|
            if supported_options.keys.include?(key)
              unless supported_options[key][:attribute]
                config[key] = builder_options.delete(key)
              end
            end
          end
        end

        def _process_builder_args!(args)
          _extract_supported_arguments!(args)
          builder_options = args.last.try(:kind_of?, Hash) ? args.last : {}
          _check_required_options(builder_options)
          _extract_supported_options!(builder_options)
          _set_defaults
          _set_id_attribute
        end

    end
  end
end