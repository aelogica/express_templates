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

  class ConfigWithOption < ETC::Configurable
    has_option :thing, 'Something about things'
  end

  test "supports option declaration" do
    markup = render { config_with_option }
    assert_equal %Q(<div class="config-with-option"></div>\n), markup
  end

  test "does not pass declared options as html attributes" do
    markup = render { config_with_option(thing: 'whatever') }
    assert_equal %Q(<div class="config-with-option"></div>\n), markup
  end

  test "unrecognized options raises an exception" do
    assert_raises(RuntimeError) do
      class ConfigWithUnrecognizedOptions < ETC::Configurable
        has_option :title, 'asdfasdf', something_unrecognized: 'whatever'
      end
    end
  end

  class ConfigWithDefaultOption < ETC::Configurable
    has_option :rows, 'Number of rows', type: :integer, default: 5, attribute: true
  end

  test "default values are supported" do
    markup = render { config_with_default_option }
    assert_equal %Q(<div class="config-with-default-option" rows="5"></div>\n), markup
  end

  test "default values for attributes can be overridden" do
    markup = render { config_with_default_option(rows: 999) }
    assert_equal %Q(<div class="config-with-default-option" rows="999"></div>\n), markup
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

  class ConfigSubclass < ConfigWithRequiredOptions
    has_option :status, 'something'
  end

  test "options are inherited" do
    assert_equal [:title, :status], ConfigSubclass.supported_options.keys
  end

end