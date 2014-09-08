module Gara
  module Template
    class Handler
      def self.call(template)
        new.call(template)
      end

      def call(template)
        # eval'd in context (self is a view context)
        %Q(Gara.render(self) { #{template.source} })
      end

    end
  end
end