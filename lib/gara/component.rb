module Gara
  class Component

    attr_accessor :children

    INDENT = '  '

    def initialize(child_or_options=nil, *children)
      @children = []
      if child_or_options.kind_of?(Hash)
        @children += children unless children.empty?
      else
        @children << child_or_options if child_or_options
        @children += children unless children.empty?
      end
    end

    def macro_name
      @macro_name ||= self.class.to_s.split('::').last.underscore
    end

    def start_tag
      "<#{macro_name}>"
    end

    def close_tag
      "</#{macro_name}>"
    end

    def compile
      ruby_fragments = @children.map do |child|
        if child.kind_of?(Gara::Component)
          child.compile
        else
          %Q("#{child}")
        end
      end
      ruby_fragments.unshift %Q("#{start_tag}")
      ruby_fragments.push %Q("#{close_tag}")
      ruby_fragments.reject {|frag| frag.empty? }.join("+")
    end

    def to_template(depth = 0)
      template_fragments = @children.map do |child|
        if child.kind_of?(Gara::Component)
          child.to_template(depth+1)
        else
          child
        end
      end
      indent = INDENT*(depth+1)
      macro_name + _blockify(template_fragments.join("\n#{indent}"), depth)
    end

    private
      def _indent(code)
        code.split("\n").map {|line| INDENT + line }.join("\n")
      end

      def _blockify(code, depth)
        indent = INDENT*depth
        code.empty? ? code : " {\n#{_indent(code)}\n}\n"
      end

  end
end