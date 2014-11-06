require 'test_helper'
require 'express_templates/interpolator'
require 'parslet/convenience'

class InterpolatorTest < ActiveSupport::TestCase

  def parse(s)
    parser = ExpressTemplates::Interpolator.new
    parsed = parser.parse_with_debug(s)
    pp parsed if ENV['DEBUG'].eql?('true')
    parsed
  end

  def transform(s)
    trans = ExpressTemplates::Transformer.new
    trans.apply(parse(s)).flatten.join
  end

  test "simplest expression parses" do
    tree = parse("{{something}}")
    expected = [{:interpolation=>{:expression=>[{:text=>"something"}]}}]
    assert_equal expected, tree
  end

  test "simple expression with surrounding text parses" do
    tree = parse('whatever {{something}} something else')
    expected = [{:text=>"whatever "},
                {:interpolation=>{:expression=>[{:text=>"something"}]}},
                {:text=>" something else"}]
    assert_equal expected, tree
  end

  test "nested without outer text parses" do
    tree = parse('{{some {{thing}} foo}}')
    expected = [{:interpolation=>
                {:expression=>
                  [{:text=>"some "},
                   {:interpolation=>{:expression=>[{:text=>"thing"}]}},
                   {:text=>" foo"}]}}]
    assert_equal expected, tree
  end

  test "nested with outer text parses" do
    tree = parse('a lot of {{something {{good}}}}')
    expected = [{:text=>"a lot of "},
                {:interpolation=>
                  {:expression=>
                    [{:text=>"something "},
                     {:interpolation=>{:expression=>[{:text=>"good"}]}}]}}]
    assert_equal expected, tree
  end

  test 'nested with multiple nested expressions parses' do
    tree = parse(%q(%Q({{foo("{{xyz}}", "{{zyx}}", bar: "baz")}})))
    expected = [{:text=>"%Q("},
                {:interpolation=>
                  {:expression=>
                    [{:text=>"foo(\""},
                     {:interpolation=>{:expression=>[{:text=>"xyz"}]}},
                     {:text=>"\", \""},
                     {:interpolation=>{:expression=>[{:text=>"zyx"}]}},
                     {:text=>"\", bar: \"baz\")"}]}},
                {:text=>")"}]
    assert_equal expected, tree
  end


  test '"{{something}}" transforms to "#{something}"' do
    assert_equal '#{something}', transform("{{something}}")
  end

  test '"{{some {{thing}} foo}}" transforms to "#{some #{thing} foo}"' do
    assert_equal '#{some #{thing} foo}', transform("{{some {{thing}} foo}}")
  end

  test %('a lot of {{something "{{good}}"}}' transforms) do
    assert_equal 'a lot of #{something "#{good}"}', transform('a lot of {{something "{{good}}"}}')
  end

end