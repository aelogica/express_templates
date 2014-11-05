require 'test_helper'

class BaseTest < ActiveSupport::TestCase

  class NoLogic < ExpressTemplates::Components::Base
    has_markup -> {
      h1 { span "Some stuff" }
    }
  end

  test ".has_markup makes compile return the block passed through express compiled" do
    assert_equal %Q("<h1><span>Some stuff</span></h1>"), NoLogic.new.compile
  end

  test "components register themselves as macros" do
    assert ExpressTemplates::Expander.instance_methods.include?(:no_logic)
  end

  class Context
    def initialize ; @foo = ['bar', 'baz'] ; end
  end

  test "fragments and has_markup are synonyms for emits" do
    assert_equal NoLogic.method(:emits), NoLogic.method(:fragments)
    assert_equal NoLogic.method(:emits), NoLogic.method(:has_markup)
  end

  class Helpers < ECB
    helper :title_helper, &-> { @foo.first }

    emits -> {
      h1 {
        title_helper
      }
    }

  end

  test "helpers defined in component are evaluated in context" do
    compiled = Helpers.new.compile
    assert_equal "<h1>bar</h1>", Context.new.instance_eval(compiled)
  end

end