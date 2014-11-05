module ExpressTemplates
  module Compiler
    def compile(template_or_src=nil, &block)
      template, src = _normalize(template_or_src)

      expander = Expander.new(template)

      Thread.current[:first_whitepace_removed] ||= 0
      Thread.current[:first_whitepace_removed] += 1
      begin
        compiled = expander.expand(src, &block).map(&:compile)
        compiled.first.sub!(/^"\n+/, '"') if Thread.current[:first_whitepace_removed].eql?(1)
        Thread.current[:first_whitepace_removed] -= 1
      ensure
        Thread.current[:first_whitepace_removed] = nil if Thread.current[:first_whitepace_removed].eql?(0)
      end

      return compiled.join("+").gsub('"+"', '').tap do |s|
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