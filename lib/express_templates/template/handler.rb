require 'ripper'

module ExpressTemplates
  module Template
    class Handler
      def self.call(template)
        new.call(template)
      end

      def call(template)
        # call ripper stuff method

        warn_contains_logic("(#{ExpressTemplates.compile(template)}).html_safe")  # pass the source code
        # returns a string to be eval'd
        "(#{ExpressTemplates.compile(template)}).html_safe"
      end

      def warn_contains_logic(compiled_template)
        keywords = %w(if until unless case for do loop while)                                                                 # array of conditional keywords
        tokens = []
        if Ripper.lex(compiled_template).select do |element|                                                                  # since it outputs an array [[line, col], type, token]
          element[1]==:on_kw                                                                                                  # type must match ':on_kw' type (type is keyword)
        end.each { |match| tokens.push(match) if keywords.include? match[2] }                                                 # check if token is in given /keyword/ array, then push to new array match
          tokens.each do |first|
            warn "PAGE TEMPLATE INCLUDES #{first[2]} STATEMENT AT LINE #{first[0][0]}: #{first}\n#{compiled_template}"        # warn on first occurence of conditional logic
          end
        end
      end
    end
  end
end
