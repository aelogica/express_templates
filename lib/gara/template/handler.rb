module Gara
  module Template
    class Handler
      def self.call(template)
        new.call(template)
      end

      def call(template)
        # returns a string to be eval'd
        Gara.render(Gara::Expander.new(template), template.source)
      end

    end
  end
end