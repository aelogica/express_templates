module ExpressTemplates
  module Components
    # NullWrap is useful for creating a node in the component tree that does
    # not produce any markup.  It can be used in a template fragment to
    # wrap bare text or string content where such would not normally be possible.
    #
    # Example:
    #
    # ```ruby
    # div {
    #   some_component
    #   null_wrap {
    #     "Some text"
    #   }
    #   other_component
    # }
    # ```
    #
    # Otherwise you can use it to hold already-complied code meant for
    # evaluation in the view that needs to be protected from being compiled
    # again. This use is largely internal to express_templates. It is not
    # expected that users of this library would need this.
    #
    # Example:
    #
    # ```ruby
    # null_wrap("(@collection.map do |member| \"<li>#{member.name}</li>\").join")
    # ```
    #
    class NullWrap < Components::Container
      def initialize(*args)
        @already_compiled_stuff = args.shift if args.first.is_a?(String)
        super(*args)
      end

      def compile
        @already_compiled_stuff || compile_children
      end
    end
  end
end
