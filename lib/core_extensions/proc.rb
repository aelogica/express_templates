require 'ripper'
require 'pp'
class Proc

  TOKEN_PAIRS = {[:on_lbrace, '{']  => [:on_rbrace, '}'],
                 [:on_kw, 'do']     => [:on_kw, 'end'],
                 [:on_tlambeg, '{'] => [:on_rbrace, '}']}

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
    remaining_tokens = tokens.slice(tokens.index(starting_token)..-1)
    nesting = -1
    while token = remaining_tokens.shift
      source_str << token[2]
      nesting += 1 if [token[1], token[2]] == starting_token_type
      is_ending_token = [token[1], token[2]].eql?(ending_token_type)
      break if is_ending_token && nesting.eql?(0)
      nesting -= 1 if is_ending_token
    end
    source_str
  end
end