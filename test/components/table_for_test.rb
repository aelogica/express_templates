require 'test_helper'
require 'ostruct'

class TableForTest < ActiveSupport::TestCase

  class Context
    def initialize(test_items)
      @test_items = test_items
    end
  end

  def test_items
    [OpenStruct.new(id: 1, name: 'Foo', price: 1.23),
     OpenStruct.new(id: 2, name: 'Bar', price: 5.49),
     OpenStruct.new(id: 3, name: 'Baz', price: 99.97)]
  end

  EXAMPLE_COMPILED = -> {
    ExpressTemplates::Components::TableFor.render_in(self) {
      "<table id=\"test_items\">
  <thead>
    <tr>
      <th class=\"name\">Name</th>
      <th class=\"price\">Price</th>
    </tr>
  </thead>

  <tbody>"+(@test_items.each_with_index.map do |test_item, test_item_index|
        "
    <tr id=\"#{(-> {"test_item-#{test_item.id}"}).call}\" class=\"test_item\">
      <td class=\"name\">#{test_item.name}</td>
      <td class=\"price\">#{(-> (price) { '$%0.2f' % price }).call(test_item.price)}</td>
    </tr>
        "
      end).join+"  </tbody>
</table>
      "
    }
  }

  EXAMPLE_MARKUP = <<-HTML
<table id="test_items">
  <thead>
    <tr>
      <th class="name">Name</th>
      <th class="price">Price</th>
    </tr>
  </thead>

  <tbody>
    <tr id="test_item-1" class="test_item">
      <td class="name">Foo</td>
      <td class="price">$1.23</td>
    </tr>

    <tr id="test_item-2" class="test_item">
      <td class="name">Bar</td>
      <td class="price">$5.49</td>
    </tr>

    <tr id="test_item-3" class="test_item">
      <td class="name">Baz</td>
      <td class="price">$99.97</td>
    </tr>
  </tbody>
</table>
  HTML


  def simple_table(test_items)
    ctx = Context.new(test_items)
    fragment = -> {
      table_for(:test_items) do |t|
        t.column :name, header: "Name"
        t.column :price, formatter: -> (price) { '$%0.2f' % price }
      end
    }
    return ctx, fragment
  end

  def example_compiled_src
    # necessary because the #source method is not perfect yet
    # ideally we would have #source_body
    EXAMPLE_COMPILED.source_body
  end

  test "example view code evaluates to example markup" do
    assert_equal EXAMPLE_MARKUP, Context.new(test_items).instance_eval(EXAMPLE_COMPILED.source_body)
  end

  test "compiled source is legible and transparent" do
    ExpressTemplates::Markup::Tag.formatted do
      ctx, fragment = simple_table(test_items)
      assert_equal example_compiled_src, ExpressTemplates.compile(&fragment)
    end
  end

  test "example compiled source renders the markup in the context" do
    ctx, fragment = simple_table(test_items)
    assert_equal EXAMPLE_MARKUP, ctx.instance_eval(example_compiled_src)
  end

  test "rendered component matches desired markup" do
    ExpressTemplates::Markup::Tag.formatted do
      ctx, fragment = simple_table(test_items)
      assert_equal EXAMPLE_MARKUP, ExpressTemplates.render(ctx, &fragment)
    end
  end

end
