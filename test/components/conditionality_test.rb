require 'test_helper'

class ConditionalityTest < ActiveSupport::TestCase

  def empty_title_context
    ctx = Object.new
    ctx.instance_variable_set(:@title, '')
    ctx
  end

  def present_title_context
    ctx = Object.new
    ctx.instance_variable_set(:@title, 'Something')
    ctx
  end

  class ConditionalRenderer < ExpressTemplates::Components::Base
    include ExpressTemplates::Components::Capabilities::Conditionality

      emits {
        h1 "{{@title}}"
      }

      only_if -> { !@title.empty? }
  end

  test "when supplied condition is false, renders empty string" do
    compiled_src = ConditionalRenderer.new.compile
    assert_equal '', empty_title_context.instance_eval(compiled_src)
  end

  test "when supplied condition is true, renders the component" do
    compiled_src = ConditionalRenderer.new.compile
    assert_equal '<h1>Something</h1>', present_title_context.instance_eval(compiled_src)
  end

end
