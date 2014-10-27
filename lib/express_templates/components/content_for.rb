module ExpressTemplates
  module Components
    # Provide a wrapper for the content_for helper which
    # accepts a block of express template code.
    #
    # Example:
    #
    # ```ruby
    # content_for(:header) {
    #   h1 "Title"
    # }
    # ```
    class ContentFor < Container
      include Capabilities::Configurable
      def compile
        children_markup = compile_children
        content_label = @args[0]
        result = %Q|content_for(:#{content_label}|
        if children_markup.empty?
          if @args[1].kind_of?(String)
            children_markup = @args[1]
            # append children as argument
            result << %Q|, "#{children_markup}".html_safe)|
          else
            # no markup specified - must be referencing the content
            result << ")"
          end
        else
          # append children in block form
          result << %Q|) { (#{children_markup.gsub(/^\s+/, '')}).html_safe }|
        end
        %Q("\#\{#{result}\}")
      end
    end
  end
end