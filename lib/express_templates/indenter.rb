module ExpressTemplates

  # Tracks current indent level scoped to the current thread.
  #
  # May be used to track multiple indents simultaneously through
  # namespacing.
  class Indenter

    DEFAULT = 2
    WHITESPACE = " "*DEFAULT

    # Returns whitespace for the named indenter or yields to a block
    # for the named indentor.
    #
    # The block is passed the current whitespace indent.
    #
    # For convenience an optional second parameter is passed to the block
    # containing a newline at the beginning of the indent.
    def self.for name
      if block_given?
        current_indenters[name] += 1
        begin
          indent = WHITESPACE * current_indenters[name]
          yield indent, "\n#{indent}"
        ensure
          if current_indenters[name].eql?(-1)
            # if we have long-lived threads for some reason
            # we want to clean up after ourselves
            current_indenters.delete(name)
          else
            current_indenters[name] -= 1
          end
        end
      else
        return WHITESPACE * current_indenters[name]
      end
    end

    private
      # For thread safety, scope indentation to the current thread
      def self.current_indenters
        Thread.current[:indenters] ||= Hash.new {|hsh, key| hsh[key] = -1 }
      end

  end

end