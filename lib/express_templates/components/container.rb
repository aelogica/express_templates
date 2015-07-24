module ExpressTemplates
  module Components
    class Container < Configurable

      class_attribute :prepended_blocks
      self.prepended_blocks = []

      class_attribute :appended_blocks
      self.appended_blocks = []

      contains -> (&block) {
        prepended
        block.call(self) if block
        appended
      }

      def prepended
        prepended_blocks.each do |block_to_prepend|
          call_block(block_to_prepend)
        end
      end

      def appended
        appended_blocks.each do |block_to_append|
          call_block(block_to_append)
        end
      end

      def call_block(block)
        instance_exec &block
      end

      def self.prepends(proc = nil, &block)
        self.prepended_blocks += [proc || block]
      end

      def self.appends(proc = nil, &block)
        self.appended_blocks += [proc || block]
      end

    end
  end
end