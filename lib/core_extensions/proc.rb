require 'ripper'
require 'pp'
class Proc

  TLAMBEG = [:on_tlambeg, "{"]
  TLAMBDA = [:on_tlambda, "->"]
  LBRACE  = [:on_lbrace, '{']

  TOKEN_PAIRS = {LBRACE             => [:on_rbrace, '}'],
                 [:on_kw, 'do']     => [:on_kw, 'end'],
                 TLAMBDA            => [:on_rbrace, '}']}

  # Make a best effort to provide the original source for a block
  # based on extracting a string from the file identified in
  # Proc#source_location using Ruby's tokenizer.
  #
  # This works for first block declared on a line in a source
  # file.  If additional blocks are specified inside the first block
  # on the same line as the start of the block, only the outer-most
  # block declaration will be identified as a the block we want.
  #
  # If you require only the source of blocks-within-other-blocks, start them
  # on a new line as would be best practice for clarity and readability.
  def source
    @source ||= begin
      file, line_no = source_location
      raise "no line number provided for source_location: #{self}" if line_no.nil?
      tokens =  Ripper.lex File.read(file)
      tokens_on_line = tokens.select {|pos, lbl, str| pos[0].eql?(line_no) }
      starting_token = tokens_on_line.detect do |pos, lbl, str|
          TOKEN_PAIRS.keys.include? [lbl, str]
      end
      starting_token_type = [starting_token[1], starting_token[2]]
      ending_token_type = TOKEN_PAIRS[starting_token_type]
      source_str = ""
      remaining_tokens = tokens[tokens.index(starting_token)..-1]
      nesting = -1
      starting_nesting_token_types = if [TLAMBDA, LBRACE].include?(starting_token_type)
        [TLAMBDA, LBRACE]
      else
        [starting_token_type]
      end

      while token = remaining_tokens.shift
        token = [token[1], token[2]] # strip position
        source_str << token[1]
        nesting += 1 if starting_nesting_token_types.include? token
        is_ending_token = token.eql?(ending_token_type)
        break if is_ending_token && nesting.eql?(0)
        nesting -= 1 if is_ending_token
      end
      source_str
    end
  end

  # Examines the source of a proc to extract the body by
  # removing the outermost block delimiters and any surrounding.
  # whitespace.
  #
  # Raises exception if the block takes arguments.
  #
  def source_body
    raise "Cannot extract proc body on non-zero arity" unless arity.eql?(0)
    tokens = Ripper.lex source
    body_start_idx = 2
    body_end_idx = -1
    if tokens[0][1].eql?(:on_tlambda)
      body_start_idx = tokens.index(tokens.detect { |t| t[1].eql?(:on_tlambeg) }) + 1
    end
    body_tokens = tokens[body_start_idx..-1]

    body_tokens.pop # ending token of proc
    # remove trailing whitespace
    whitespace = [:on_sp, :on_nl, :on_ignored_nl]
    body_tokens.pop while whitespace.include?(body_tokens[-1][1])
    # remove leading whitespace
    body_tokens.shift while whitespace.include?(body_tokens[0][1])

    # put them back together
    body_tokens.map {|token| token[2] }.join
  end

  def self.from_source(prc_src)
    raise ArgumentError unless prc_src.kind_of?(String)
    prc = begin
      eval(prc_src)
    rescue ArgumentError => e
      binding.pry
    end
    prc.instance_variable_set(:@source, prc_src)
    prc
  end

end