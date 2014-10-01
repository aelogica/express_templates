module ExpressTemplates
  module Template
    class Handler
      def self.call(template)
        new.call(template)
      end

      def call(template)
        # returns a string to be eval'd
        ExpressTemplates.compile(template)
      end

    end
  end
end