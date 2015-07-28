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

  test "#source work with a stabby lambda spanning lines" do
    block = return_block -> {
  whatever { foo }
}
    assert_equal "-> {\n  whatever { foo }\n}", block.source
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

  test ".from_source stores source of a dynamicly built proc for later inspection" do
    src = "-> { 'foo' }"
    assert_equal src, Proc.from_source(src).source
    assert_equal 'foo', Proc.from_source(src).call
  end

  test ".source_body captures full body when parens around parameters not provided" do
    block = return_block { something(:one, "two") }
    assert_equal 'something(:one, "two")', block.source_body
    block = return_block -> { something :one, "two" }
    assert_equal 'something :one, "two"', block.source_body
    # TODO: Fix this
    # block = return_block { something :one, "two" }
    # assert_equal 'something :one, "two"', block.source_body
  end

  def return_proc_value(*args, options)
    options.values.first.values.first
  end

  test "#source works when a proc is inside a hash literal" do
    block = return_proc_value(:one, two: {a: -> {'proc_inside'}})
    assert_equal "-> {'proc_inside'}", block.source
  end

end
