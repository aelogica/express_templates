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
      span { item }
    }

    for_each(:@foo)
  end

  test ".for_each iterates markup for each value" do
    compiled = ForEachLogic.new.compile
    assert_equal '<span>bar</span><span>baz</span>', Context.new.instance_eval(compiled)
  end

  class MultiFragments < ECB
    def self.markup
      return -> {
        h1 { span "something" }
      }
    end

    renders markup: markup,
    wrapper: -> {
      head {
        # yield
      }
    }

    using_logic { |c|
      c.content_for(:wrapper) {
        c.render(:markup)
      }
    }
  end

  test "renders is synonymous for emits" do
    assert_equal ExpressTemplates.compile(&MultiFragments.markup), MultiFragments[:markup]
  end

end