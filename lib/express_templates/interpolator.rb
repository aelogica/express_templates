require 'parslet'

module ExpressTemplates
  class Interpolator < Parslet::Parser
    rule(:lbrace)         { str('{{') }
    rule(:rbrace)         { str('}}') }
    rule(:delim)          { lbrace | rbrace }
    rule(:lpart)          { (lbrace.absnt? >> any).repeat.as(:lpart) }
    rule(:rpart)          { (rbrace.absnt? >> any).repeat.as(:rpart) }
    rule(:expression)     { (text_with_interpolations).as(:expression) }
    rule(:interpolation)  { (lbrace>>expression>>rbrace).as(:interpolation) }
    rule(:text)           { (delim.absnt? >> any).repeat(1) }
    rule(:text_with_interpolations) { (text.as(:text) | interpolation).repeat }
    root(:text_with_interpolations)

    def self.transform(s)
      begin
        Transformer.new.apply(new.parse(s)).flatten.join
      rescue Parslet::ParseFailed => failure
        puts s
        puts failure.cause.ascii_tree
        raise failure
      end
    end
  end

  class Transformer < Parslet::Transform
    rule(:interpolation => simple(:expression)) {
      '#{'+expression+'}'
    }
    rule(:expression => sequence(:exp))      do
      exp.map(&:to_s).join.gsub('\\"', '"')
    end
    rule(:text => simple(:s)) { s.to_s }
  end
end