module ExpressTemplates
  module Template
    class Handler
      def self.call(template)
        new.call(template)
      end

      def call(template)
        # returns a string to be eval'd
        if ENV['PRETTY_HTML'].eql?("true")
          require 'nokogiri'
          "Nokogiri::XML::DocumentFragment.parse(#{ExpressTemplates.compile(template)}).to_xhtml.html_safe"
        else
          "(#{ExpressTemplates.compile(template)}).html_safe"
        end
      end

    end
  end
end