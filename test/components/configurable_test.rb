require 'test_helper'

class ConfigurableTest < ActiveSupport::TestCase

  class Context
    def assigns
      {}
    end
  end

  def render(&block)
    ExpressTemplates.render(Context.new, &block)
  end

  ETC = ExpressTemplates::Components

  class ConfigurableComponent < ETC::Configurable
  end

  test "renders id argument as dom id" do
    assert_match /id="foo"/, render { configurable_component(:foo) }
  end

  test "has no id attribute if not specified" do
    assert_no_match /id="foo"/, render { configurable_component }
  end

  class ConfigWithOptions < ETC::Configurable
    has_option :thing, 'Something about things'
    has_option :rows, 'Number of rows', type: :integer, default: 5
  end

  test "supports option declaration" do
    compiled_src = render { config_with_options }
    assert_equal %Q(<div class="config-with-options"></div>\n), compiled_src
  end

  test "does not pass declared options as html attributes" do
    compiled_src = render { config_with_options(thing: 'whatever') }
    assert_equal %Q(<div class="config-with-options"></div>\n), compiled_src
  end

  test "unrecognized options raises an exception" do
    assert_raises(RuntimeError) do
      class ConfigWithUnrecognizedOptions < ETC::Configurable
        has_option :title, 'asdfasdf', something_unrecognized: 'whatever'
      end
    end
  end

  class ConfigWithRequiredOptions < ETC::Configurable
    has_option :title, 'adds a title', required: true
  end

  test "required options are required" do
    assert_raises(RuntimeError) do
      render { config_with_required_options }
    end
    assert render { config_with_required_options(title: 'foo') }
  end


end