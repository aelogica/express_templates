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
          when name.to_sym.eql?(:data) && value.kind_of?(Hash)
            value.each_pair.map {|k,v| %Q(data-#{k}=\\"#{v}\\") }.join(" ")
          when code = value.to_s.match(/^\{\{(.*)\}\}$/).try(:[], 1)
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
        ExpressTemplates::Indenter.for(:markup) do |whitespace|
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
            _wrap_with_tags(ruby_fragments, whitespace)
          else
            if should_not_abbreviate?
              _wrap_with_tags(ruby_fragments, whitespace)
            else
              %Q("#{start_tag.gsub(/>$/, ' />')}")
            end
          end
        end
      end

      def to_template
        # ExpressTemplates::Indenter.for(:template) do
          template_fragments = @children.map do |child|
            if child.respond_to?(:to_template)
              child.to_template
            else
              child
            end
          end
          macro_name + _blockify(template_fragments.join("\n"))
        # end
      end

      def self.formatted
        old_setting = Thread.current[:formatted]
        begin
          Thread.current[:formatted] = true
          yield if block_given?
        ensure
          Thread.current[:formatted] = old_setting
        end
      end

      private

        def _wrap_with_tags(ruby_fragments, whitespace)
          opening = %Q("#{start_tag}")
          closing = %Q("#{close_tag}")
          if !ENV['ET_NO_INDENT_MARKUP'].eql?('true') || #TODO: change to setting
              Thread.current[:formatted]
            child_code = ruby_fragments.join
            should_multi_line = ruby_fragments.size > 1 ||
                                child_code.size > 40 ||
                                child_code.match(/\n/)

            nl = should_multi_line ? "\n" : nil
            avoid_double_nl = !ruby_fragments.first.try(:match, /"\n/) ? nl : nil
            opening = %Q("\n#{whitespace}#{start_tag}#{avoid_double_nl}")
            closing = %Q("#{nl}#{nl && whitespace}#{close_tag}#{nl}")
          end
          ruby_fragments.unshift opening
          ruby_fragments.push closing
          ruby_fragments.reject {|frag| frag.empty? }.join("+")
        end

        def _indent(code)
          code.split("\n").map {|line| ExpressTemplates::Indenter::WHITESPACE + line }.join("\n")
        end

        def _blockify(code)
          code.empty? ? code : " {\n#{_indent(code)}\n}\n"
        end

    end
  end
end