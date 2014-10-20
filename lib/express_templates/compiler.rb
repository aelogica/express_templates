module ExpressTemplates
  module Compiler
    def compile(template_or_src=nil, &block)
      template, src = _normalize(template_or_src)

      expander = Expander.new(template)

      compiled = expander.expand(src, &block).map(&:compile)

      return compiled.join("+").tap do |s| 
        puts("\n"+template.inspect+"\n"+s) if ENV['DEBUG'].eql?('true')
      end
    end

    private
      def _normalize(template_or_src)
        template, src = nil, nil
        if template_or_src.respond_to?(:source)
          template = template_or_src
          src = template_or_src.source
        else
          src = template_or_src
        end
        return template, src
      end
  end
end