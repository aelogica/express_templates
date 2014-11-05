module ExpressTemplates
  module Components
    class UnlessBlock < Components::Container

      attr :conditional

      def initialize(*args)
        @conditional = args.shift
        @alt = args.shift[:alt] if args.first.kind_of?(Hash)
        parent = args.shift
        if @conditional.kind_of?(Symbol)
          @conditional = @conditional.to_s
        elsif @conditional.kind_of?(Proc)
          @conditional = "(#{@conditional.source}.call)"
        elsif iterator.kind_of?(String)
          @conditional = "(#{@conditional}.call)"
        else
          raise "UnlessBlock unknown conditional: #{@conditional.inspect}"
        end

        if @alt.kind_of?(Proc)
          @alt = _compile_fragment @alt
        elsif @alt.nil?
          @alt = "''"
        end
      end

      def compile
        s = unless @alt
          %Q((unless #{@conditional}#{compile_children}\nend))
        else
          %Q((unless #{@conditional}#{compile_children}\nelse #{@alt}\nend))
        end
        puts s if ENV['DEBUG'].eql?('true')
        s
      end

    end
  end
end
