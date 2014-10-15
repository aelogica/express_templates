require 'test_helper'

class ProcTest < ActiveSupport::TestCase

  def return_block(&block)
    return block
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


end
