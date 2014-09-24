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

  class SomeLogic < ExpressTemplates::Components::Base
    emits markup: -> {
      span { foo }
    }

    using_logic { |markup_code|
      @foo.map do |foo|
        eval(markup_code)
      end.join
    }
  end

  class Context
    def initialize ; @foo = ['bar', 'baz'] ; end
  end

  test ".using_logic controls the markup generation" do
    compiled = SomeLogic.new.compile
    assert_equal 'BaseTest::SomeLogic.control(self, \'"<span>"+"#{foo}"+"</span>"\')', compiled
    assert_equal '<span>bar</span><span>baz</span>', Context.new.instance_eval(compiled)
  end


end