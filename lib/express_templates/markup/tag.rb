module ExpressTemplates
  module Markup
    class Tag

      attr_accessor :children

      INDENT = '  '

      def initialize(*children_or_options)
        @children = []
        @options = {}.with_indifferent_access
        _process(*children_or_options)
      end

      def self.macro_name
        @macro_name ||= to_s.split('::').last.underscore
      end

      def macro_name ; self.class.macro_name end

      def html_options
        @options.each_pair.map do |name, value|
          case
          when code = value.match(/\{\{(.*)\}\}/).try(:[], 1)
            %Q(#{name}=\\"\#{#{code}}\\")
          else
            %Q(#{name}=\\"#{value}\\")
          end
        end.join(" ")
      end

      def start_tag
        "<#{macro_name}#{html_options.empty? ? '' : ' '+html_options}>"
      end

      def close_tag
        "</#{macro_name}>"
      end

      def add_css_class(css_class)
        @options['class'] ||= ''
        @options['class'] = (@options['class'].split + [css_class]).join(" ")
      end

      def method_missing(name, *args)
        add_css_class(name)
        _process(*args) unless args.empty?
        return self
      end

      def compile
        ruby_fragments = @children.map do |child|
          if child.respond_to?(:compile)
            child.compile
          else
            %Q("#{child}")
          end
        end
        unless ruby_fragments.empty?
          ruby_fragments.unshift %Q("#{start_tag}")
          ruby_fragments.push %Q("#{close_tag}")
          ruby_fragments.reject {|frag| frag.empty? }.join("+")
        else
          %Q("#{start_tag.gsub(/>$/, ' />')}")
        end
      end

      def to_template(depth = 0)
        template_fragments = @children.map do |child|
          if child.respond_to?(:to_template)
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

        def _process(*children_or_options)
          children_or_options.each do |child_or_option|
            if child_or_option.kind_of?(Hash)
              @options.merge!(child_or_option)
            else
              @children << child_or_option
            end
          end
        end

    end
  end
end