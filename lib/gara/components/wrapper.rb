module Gara
  module Components
    # wrap locals and helpers for evaluation during render
    class Wrapper

      attr_accessor :name, :args

      def initialize(name, *args)
        @name = name
        @args = args
      end

      def compile
        if @args.empty?
          return name
        else
          args_string = args.slice(0..-2).map(&:inspect).join(', ')
          last_arg = ''
          if args.last.is_a?(Hash) # expand a hash
            unless args.last.empty?
              last_arg = args.last.inspect.match(/^\{(.*)\}$/)[1]
              last_arg.gsub!(/:(\w+)=>/, '\1: ')
            else
              last_arg = "{}"
            end
          else
            last_arg = args.last.inspect
          end
          args_string << (args_string.empty? ? last_arg : ", #{last_arg}")
          return "#{name}(#{args_string})"
        end
      end

      def to_template
        compile
      end
    end
  end
end
