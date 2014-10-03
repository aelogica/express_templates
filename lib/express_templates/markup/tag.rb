module ExpressTemplates
  module Markup
    class Tag
      include ExpressTemplates::Macro

      attr_accessor :children

      INDENT = '  '

      # These come from Macro but must remain overridden here for performance reasons.
      # To verify, comment these two methods and
      # run rake test and observe the performance hit.  Why?
      def self.macro_name
        @macro_name ||= to_s.split('::').last.underscore
      end

      def macro_name ; self.class.macro_name end


      def html_options
        @options.each_pair.map do |name, value|
          case
          when code = value.to_s.match(/\{\{(.*)\}\}/).try(:[], 1)
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
        css_class = css_class.to_s.gsub('_', '-').gsub(/^-/,'') if css_class.to_s.match /^_.*_/
        @options['class'] = (@options['class'].split + [css_class]).uniq.join(" ")
      end

      def method_missing(name, *args, &children)
        add_css_class(name)
        _process(*args) unless args.empty?
        if children # in the case where CSS classes are specified via method
          unless @expander.nil?
            @expander.process_children! self, &children
          else
            raise "block passed without expander"
          end
        end
        return self
      end

      def should_not_abbreviate?
        false
      end

      def compile
        ruby_fragments = @children.map do |child|
          if child.respond_to?(:compile)
            child.compile
          else
            if code = child.to_s.match(/\{\{(.*)\}\}/).try(:[], 1)
              %Q("\#\{#{code}\}")
            else
              %Q("#{child}")
            end
          end
        end
        unless ruby_fragments.empty?
          _wrap_with_tags(ruby_fragments)
        else
          if should_not_abbreviate?
            _wrap_with_tags(ruby_fragments)
          else
            %Q("#{start_tag.gsub(/>$/, ' />')}")
          end
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

        def _wrap_with_tags(ruby_fragments)
          ruby_fragments.unshift %Q("#{start_tag}")
          ruby_fragments.push %Q("#{close_tag}")
          ruby_fragments.reject {|frag| frag.empty? }.join("+")
        end

        def _indent(code)
          code.split("\n").map {|line| INDENT + line }.join("\n")
        end

        def _blockify(code, depth)
          indent = INDENT*depth
          code.empty? ? code : " {\n#{_indent(code)}\n}\n"
        end

    end
  end
end