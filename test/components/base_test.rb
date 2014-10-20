require 'test_helper'

class BaseTest < ActiveSupport::TestCase

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

  test ".render accepts a fragment name" do
    assert_equal '<h1><span>Some stuff</span></h1>', NoLogic.render(self, :markup)
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

  test "fragments and has_markup are synonyms for emits" do
    assert_equal SomeLogic.method(:emits), SomeLogic.method(:fragments)
    assert_equal SomeLogic.method(:emits), SomeLogic.method(:has_markup)
  end

  class Helpers < ECB
    helper :title_helper, &-> { @foo.first }

    emits {
      h1 {
        title_helper
      }
    }

  end

  test "helpers defined in component are evaluated in context" do
    compiled = Helpers.new.compile
    assert_equal "<h1>bar</h1>", Context.new.instance_eval(compiled)
  end

  class NullComponent < ECB
    using_logic {
      nil
    }
  end

  test "render should not return a nil" do
    compiled = NullComponent.new.compile
    assert_equal "", Context.new.instance_eval(compiled)
  end
end