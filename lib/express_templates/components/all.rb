module ExpressTemplates
  module Components
    class All < Container

      has_argument :id, "Name of the collection", as: :collection_name, type: :symbol

      contains -> (&block) {
        prepended
        collection.each do |item|
          assigns[member_name.to_sym] = item
          block.call(self) if block
        end
        appended
      }

      def member_name
        config[:collection_name].to_s.singularize.to_sym
      end

      def collection
        self.send(config[:collection_name])
      end

    end
  end
end
