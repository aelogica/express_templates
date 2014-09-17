require 'test_helper'

class ExpanderStackTest < ActiveSupport::TestCase

  def new_stack
    Gara::Expander::Stack.new
  end

  test "#current is empty" do
    assert_empty new_stack.current
  end

  test "#<< adds something to the current" do
    stack = new_stack
    stack << 'foo'
    assert_equal ['foo'], stack.current
  end

  test "#all returns the stack" do
    assert_equal [[]], new_stack.all
  end

  test "#descend! adds a level to the stack and updates current" do
    stack = new_stack
    stack << 'foo'
    level = stack.descend!
    assert_equal 2, stack.all.count
    assert_equal [], stack.current
    assert_equal 1, level
  end

  test "#ascend!" do
    stack = new_stack
    stack << 'foo'
    level_1 = stack.descend!
    level_2 = stack.descend!
    level = stack.ascend!
    assert_equal level_1, level
  end

end