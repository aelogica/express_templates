module ExpressTemplates
  module Compiler
    def compile(template_or_src=nil, &block)

      template, src = _normalize(template_or_src)

      %Q[Arbre::Context.new(assigns.merge(template_virtual_path: @virtual_path), self) { #{src || block.source_body} }.to_s]
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