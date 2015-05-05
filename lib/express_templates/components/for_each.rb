module ExpressTemplates
  module Components
    class ForEach < Components::Container
      attr :collection, :member

      def initialize(*args)
        iterator = args.shift
        options = args.first.kind_of?(Hash) ? args.shift : {}
        expander = args.shift
        @collection, @member = nil, (options[:as]||"item")
        if iterator.kind_of?(Symbol)
          @collection = iterator.to_s
          @member = collection.sub(/^@/, '').singularize
        elsif iterator.kind_of?(Proc)
          @collection = "(#{iterator.source}.call)"
        elsif iterator.kind_of?(String)
          @collection = "(#{iterator}.call)"
        else
          raise "ForEach unknown iterator: #{iterator}"
        end
      end


      def compile
        %Q((#{@collection}.each_with_index.map do |#{@member}, #{@member}_index|#{compile_children}\nend).join)
      end

    end
  end
end
