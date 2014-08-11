module Gara
  module Template
    class Handler
      def self.call(template)
        new.call(template)
      end

      def call(template)
        %Q(delegate = Gara::ContextDelegate.new(self); #{template.source} ; delegate.to_html)
      end

    end
  end
end