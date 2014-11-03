require 'test_helper'

class ProcTest < ActiveSupport::TestCase

  def return_block(lambda = nil, &block)
    return block || lambda
  end

  test "#source returns a proc's source" do
    block = return_block { |f|
      do_something
    }
    assert_equal "{ |f|\n      do_something\n    }", block.source
  end

  test "#source works with a do block" do
    block = return_block do |f|
      do_something
    end

    assert_equal "do |f|\n      do_something\n    end", block.source
  end

  test "#source works with a single line block" do
    block = return_block { whatever }
    assert_equal '{ whatever }', block.source
  end

  test "#source works with a block containing a block" do
    block = return_block { whatever { another } }
    assert_equal '{ whatever { another } }', block.source
  end

  test "#source works with a stabby lambda" do
    block = return_block -> (something) { whatever }
    assert_equal '-> (something) { whatever }', block.source
  end

  test "#source_body returns the body of a proc" do
    block = return_block -> { whatever }
    assert_equal 'whatever', block.source_body
  end

  test "#source_body handles funky bodies" do
    block = return_block do
      something(funky) &-> { whatever }
    end
    assert_equal 'something(funky) &-> { whatever }', block.source_body
  end

  test "#source body raises exception for arity > 0" do
    block = return_block -> (foo) { whatever }
    assert_raises(RuntimeError) do
      block.source_body
    end
  end

end
