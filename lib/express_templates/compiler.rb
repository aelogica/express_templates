require 'ostruct'
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

      %Q|
Arbre::Context.new(assigns.merge(template_virtual_path: @virtual_path), self) {
  #{src || block.source_body}
}.to_s
|
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