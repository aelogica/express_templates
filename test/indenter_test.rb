require 'test_helper'

class IndenterTest < ActiveSupport::TestCase

  Indenter = ExpressTemplates::Indenter

  test ".for(:name) takes a block receiving whitespace" do
    Indenter.for(:foo) do
      assert_equal "\n  ", Indenter.for(:foo) { |indent, indent_with_newline| indent_with_newline }
      assert_equal "  ", Indenter.for(:foo) { |indent, indent_with_newline| indent }
    end
  end

  test "nesting blocks increases whitespace accordingly" do
    nested_whitespace = Indenter.for(:foo) do |ws1|
      Indenter.for(:foo) do |ws2|
        ws2
      end
    end
    assert_equal "  ", nested_whitespace
  end

  test ".for(:name) returns current indent without newline when block is not given" do
    assert_equal "", Indenter.for(:foo) { |_| Indenter.for(:foo) }
  end

end