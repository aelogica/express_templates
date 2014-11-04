require 'test_helper'

class IteratingTest < ActiveSupport::TestCase

  class Context
    def initialize ; @things = ['bar', 'baz'] ; @empty = [] ; end
  end

  class ForEachLogic < ECB
    emits -> {
      for_each(:@things) {
        span { thing }
      }
    }
  end

  test "#for_each expands to view logic" do
    compiled = ForEachLogic.new.compile
    assert_equal %q((@things.map do |thing|
  "<span>#{thing}</span>"
 end).join), compiled
  end

  test "#for_each iterates markup for each value" do
    compiled = ForEachLogic.new.compile
    assert_equal '<span>bar</span><span>baz</span>', Context.new.instance_eval(compiled)
  end

  class ForEachDeclarativeForm < ECB
    emits -> {
      span { thing }
    }

    for_each(:@things)
  end

  test ".for_each offers declarative form" do
    compiled = ForEachLogic.new.compile
    assert_equal '<span>bar</span><span>baz</span>', Context.new.instance_eval(compiled)
  end


  class MultiFragments < ECB

    fragments item:  -> {
                          li { thing }
                        },

              wrapper: -> {
                            ul {
                              _yield
                            }
                          }

    for_each -> { @things }, as: 'thing', emit: :item

    wrap_with :wrapper

  end

  test ".wrap_with wraps via _yield special handler" do
    compiled = MultiFragments.new.compile
    assert_equal "<ul><li>bar</li><li>baz</li></ul>", Context.new.instance_eval(compiled)
  end

  class EmptyState < ECB

    fragments item:       -> {
                                li { thing }
                              },

              wrapper:    -> {
                                ul {
                                  _yield
                                }
                             },
              empty_state: -> {
                                p "Nothing here"
                              }

    for_each -> { @empty }, as: 'thing', emit: :item, empty: :empty_state

    wrap_with :wrapper, dont_wrap_if: -> { @empty.empty? }

  end

  test "empty state renders when collection is empty" do
    compiled = EmptyState.new.compile
    assert_equal '<p>Nothing here</p>', Context.new.instance_eval(compiled)
  end

  class EmptyEmptyState < ECB
    emits -> {
      whatever
    }

    for_each -> { @empty }
  end

  test "if collection is empty and no empty fragment specified, empty string is rendered" do
    compiled = EmptyEmptyState.new.compile
    assert_equal '', Context.new.instance_eval(compiled)
  end


end