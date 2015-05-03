module ExpressTemplates
  module Compiler
    def compile(template_or_src=nil, &block)

      if block
        begin
          block.source
        rescue
          raise "block must have source - did you do compile(&:label) ?"
        end
      end

      template, src = _normalize(template_or_src)

      expander = Expander.new(template)

      compiled = expander.expand(src, &block).map(&:compile)

      return Interpolator.transform(compiled.join("+").gsub('"+"', '')).tap do |s|
        puts("\n"+template.inspect+"\nSource:\n#{template.try(:source)}\nInterpolated:\n#{s}\n") if ENV['DEBUG'].eql?('true')
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