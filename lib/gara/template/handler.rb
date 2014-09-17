module Gara
  module Template
    class Handler
      def self.call(template)
        new.call(template)
      end

      def call(template)
        # returns a string to be eval'd
        Gara::Expander.expand(template, template.source)
      end

    end
  end
end