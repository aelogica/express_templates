require 'test_helper'

class BaseTest < ActiveSupport::TestCase

  ECB = ExpressTemplates::Components::Base

  class NoLogic < ExpressTemplates::Components::Base
    has_markup {
      h1 { span "Some stuff" }
    }
  end

  test ".has_markup makes compile return the block passed through express compiled" do
    assert_equal %Q("<h1>"+"<span>"+"Some stuff"+"</span>"+"</h1>"), NoLogic.new.compile
  end

  test "components register themselves as macros" do
    assert ExpressTemplates::Expander.instance_methods.include?(:no_logic)
  end

  class SomeLogic < ECB
    emits markup: -> {
      span { foo }
    }

    using_logic { |component|
      @foo.map do |foo|
        eval(component[:markup])
      end.join
    }
  end

  class Context
    def initialize ; @foo = ['bar', 'baz'] ; end
  end

  test ".using_logic controls the markup generation" do
    compiled = SomeLogic.new.compile
    assert_equal 'BaseTest::SomeLogic.render(self)', compiled
    assert_equal '<span>bar</span><span>baz</span>', Context.new.instance_eval(compiled)
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

    for_each :@foo, emit: :item

    wrap_with :wrapper

  end

  test "fragments and renders are synonyms for emits" do
    assert_equal MultiFragments.method(:emits), MultiFragments.method(:fragments)
    assert_equal MultiFragments.method(:emits), MultiFragments.method(:renders)
  end

  test ".wrap_with wraps via _yield special handler" do
    compiled = MultiFragments.new.compile
    assert_equal "<ul><li>bar</li><li>baz</li></ul>", Context.new.instance_eval(compiled)
  end

end