require 'test_helper'

class BaseTest < ActiveSupport::TestCase

  def assigns
    {}
  end

  class NoLogic < ExpressTemplates::Components::Base
    emits {
      h1 { span "Some stuff" }
    }
  end

  test ".has_markup makes compile return the block passed through express compiled" do
    assert_equal "<h1>\n  <span>Some stuff</span>\n</h1>\n", ExpressTemplates.render(self) { no_logic }
  end

  test "components register themselves as arbre builder methods" do
    assert Arbre::Element::BuilderMethods.instance_methods.include?(:no_logic)
  end

  class Context
    def assigns
      {:foo => ['bar', 'baz']}
    end
  end

  class HelperExample < ECB
    def title_helper
      foo.first
    end

    emits {
      h1 {
        title_helper
      }
    }

  end

  test "helpers defined in component are evaluated in context" do
    assert_equal "<h1>bar</h1>\n", ExpressTemplates.render(Context.new) { helper_example }
  end

end