require 'test_helper'

class IteratingTest < ActiveSupport::TestCase

  class Context
    def initialize ; @foo = ['bar', 'baz'] ; @empty = [] ; end
  end

  class ForEachLogic < ECB
    emits -> {
      span { foo }
    }

    for_each(:@foo)
  end

  test ".for_each iterates markup for each value" do
    compiled = ForEachLogic.new.compile
    assert_equal '<span>bar</span><span>baz</span>', Context.new.instance_eval(compiled)
  end

  class MultiFragments < ECB

    fragments item:  -> {
                          li { foo }
                        },

              wrapper: -> {
                            ul {
                              _yield
                            }
                          }

    for_each -> { @foo }, as: 'foo', emit: :item

    wrap_with :wrapper

  end

  test ".wrap_with wraps via _yield special handler" do
    compiled = MultiFragments.new.compile
    assert_equal "<ul><li>bar</li><li>baz</li></ul>", Context.new.instance_eval(compiled)
  end

  class EmptyState < ECB

    fragments item:       -> {
                                li { foo }
                              },

              wrapper:    -> {
                                ul {
                                  _yield
                                }
                             },
              empty_state: -> {
                                p "Nothing here"
                              }

    for_each -> { @empty }, as: 'foo', emit: :item, empty: :empty_state

    wrap_with :wrapper, dont_wrap_if: -> { @empty.empty? }

  end

  test "empty state renders when collection is empty" do
    compiled = EmptyState.new.compile
    assert_equal '<p>Nothing here</p>', Context.new.instance_eval(compiled)
  end


end