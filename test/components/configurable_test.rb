require 'test_helper'

class ConfigurableTest < ActiveSupport::TestCase

  ETC = ExpressTemplates::Components

  class ConfigurableComponent < ETC::Configurable
    def markup
      div(id: my[:id], class: 'bar')
    end
  end

  test "renders id argument as dom id" do
    compiled_src = ExpressTemplates.render(self) { configurable_component(:foo) }
    assert_equal "<div id=\"foo\" class=\"bar\"></div>\n", compiled_src
  end

  class ConfigurableContainerComponent < ETC::Configurable

    # make sure a helper can take arguments
    # helper(:name) {|name| name.to_s }
    def name(name)
      name.to_s
    end

    def markup &block
      div(id: my[:id]) {
        h1 { name(my[:id]) }
        yield(block) if block
      }
    end
  end

  def assigns
    {}
  end

  test "a configurable component may have also be a container" do
    html = ExpressTemplates.render(self) { configurable_container_component(:foo) { |c| para 'bar'} }
    expected = <<-HTML
<div id=\"foo\">
  <h1>foo</h1>
  <p>bar</p>
</div>
HTML
    assert_equal "<div id=\"foo\">\n  <h1>foo</h1>\n  <p>bar</p>\n</div>\n", html
  end

end