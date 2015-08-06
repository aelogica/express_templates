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

  ETCC = ExpressTemplates::Components::Configurable

  class ConfigurableComponent < ETCC
  end

  test "renders first argument as dom id" do
    assert_match /id="foo"/, render { configurable_component(:foo) }
  end

  test "has no id attribute if not specified" do
    assert_no_match /id="foo"/, render { configurable_component }
  end

  class ConfigWithOption < ETCC
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
    assert_raises(ArgumentError) do
      class ConfigWithUnrecognizedOptions < ETCC
        has_option :title, 'asdfasdf', something_unrecognized: 'whatever'
      end
    end
  end

  class ConfigWithDefaultOption < ETCC
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

  class ConfigWithRequiredOptions < ETCC
    has_option :title, 'adds a title', required: true
  end

  test "required options are required" do
    assert_raises(RuntimeError) do
      render { config_with_required_options }
    end
    assert render { config_with_required_options(title: 'foo') }
  end

  class ConfigWithOptionValues < ETCC
    has_option :virtual, 'gets the virtual_attributes of a resource', values: -> (*) { resource_class.virtual_attributes }

    def resource_class
      OpenStruct.new(virtual_attributes: [:password, :password_confirmation])
    end
  end

  test "values can be set for options" do
    component = ConfigWithOptionValues.new
    assert_equal [:password, :password_confirmation], component.instance_eval(&ConfigWithOptionValues.new.supported_options[:virtual][:values])
  end

  class ConfigSubclass < ConfigWithRequiredOptions
    has_option :status, 'something'
  end

  test "options are inherited" do
    assert_equal [:title, :status], ConfigSubclass.supported_options.keys
  end

  class ConfigArgument < ETCC
    has_argument :name, "The name.", type: :string

    has_option :something, "else"

    contains {
      text_node config[:name]
    }
  end

  test ".has_argument adds a positional configuration argument" do
    assert_equal :name, ConfigArgument.new.supported_arguments.keys.last
    assert_equal "The name.", ConfigArgument.new.supported_arguments.values.last[:description]
  end

  test ".has_argument makes builder arguments accessible by name according to position" do
    html = render &-> {
      config_argument :bar, 'Foo'
    }
    assert_match />Foo</, html
  end

  class ConfigAnotherArgument < ConfigArgument
    has_argument :title, "comes after name", type: :string
  end

  test ".has_argument appends supported arguments in order of inheritence" do
    assert_equal [:id, :name, :title], ConfigAnotherArgument.new.supported_arguments.keys
  end

  class ConfigOverwriteId < ConfigArgument
    has_argument :id, 'Should overwrite :id',
                      as: :foo, type: :symbol
    contains -> {
      text_node config[:foo]
    }
  end

  test ".has_argument as: allows overwrite of inherited argument" do
    html = render {
      config_overwrite_id(:whatever, 'Ignore me')
    }
    assert_match /div.*>whatever/, html
  end
end
