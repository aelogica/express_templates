require 'test_helper'

class GaraTest < ActiveSupport::TestCase
  test "we have a module" do
    assert_kind_of Module, Gara
  end

  test "Gara.render renders a template" do
    result = Gara.render(self) do
      ul {
        li 'one'
        li 'two'
        li 'three'
      }
    end
    assert_equal "<ul>\n<li>one</li>\n<li>two</li>\n<li>three</li>\n</ul>", result
  end

  test "performance is okay" do

  end

  class TestEmitter
    module DelegatedMethods
      def component1 ; @gara_delegate.component1 ; yield if block_given? ; end
      def component2 ; @gara_delegate.component2 ; yield if block_given? ; end
    end

    def initialize
      @doc = ""
    end
    def component1 ; @doc << "stuff " ; end
    def component2 ; @doc << "and more stuff" ; end

    def registered_methods
      return DelegatedMethods
    end
    def emit
      @doc
    end
  end

  test "another emitter may be supplied" do
    result = Gara.render(self, TestEmitter.new) {
      component1 {
        component2
      }
    }
    assert_equal "stuff and more stuff", result
  end
end
