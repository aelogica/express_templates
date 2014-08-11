module Gara
  module Template
    class Handler
      def self.call(template)
        new.call(template)
      end

      def call(template)
        %Q(Gara::Delegator.new(self) { #{template.source} }.to_html)
      end

    end
  end
end