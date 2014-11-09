require 'test_helper'
require 'ostruct'

class TreeForTest < ActiveSupport::TestCase
  class Context
    def initialize(roles)
      @roles = roles
    end
  end

  class Role
    attr :name, :children
    def initialize(name, children: [])
      @name = name
      @children = children
    end
  end

  def roles
    [Role.new('SuperAdmin', children:
          [Role.new('Admin', children:
            [Role.new('Publisher', children:
              [Role.new('Author')]),
             Role.new('Auditor')])])]
  end

  EXAMPLE_COMPILED = -> {
ExpressTemplates::Components::TreeFor.render_in(self) {
  node_renderer = -> (role, renderer) {
    ExpressTemplates::Indenter.for(:tree) do |ws, wsnl|
      "#{wsnl}<li>"+
     "#{role.name}"+
      if role.children.any?
        ExpressTemplates::Indenter.for(:tree) do |ws, wsnl|
          "#{wsnl}<ul>" +
            role.children.map do |child|
              renderer.call(child, renderer)
            end.join +
          "#{wsnl}</ul>"
        end +
        "#{wsnl}</li>"
      else
        "</li>"
      end
    end
  }
  ExpressTemplates::Indenter.for(:tree) do |ws, wsnl|
    "#{ws}<ul id=\"roles\" class=\"roles tree\">" +
      @roles.map do |role|
        node_renderer.call(role, node_renderer)
      end.join +
    "#{wsnl}</ul>\n"
  end
}
}

  EXAMPLE_MARKUP = <<-HTML
<ul id="roles" class="roles tree">
  <li>SuperAdmin
    <ul>
      <li>Admin
        <ul>
          <li>Publisher
            <ul>
              <li>Author</li>
            </ul>
          </li>
          <li>Auditor</li>
        </ul>
      </li>
    </ul>
  </li>
</ul>
HTML

  def simple_tree_for(roles)
    ctx = Context.new(roles)
    fragment = -> {
                    tree_for(:roles) {
                      "{{role.name}}"
                    }
                  }
    return ctx, fragment
  end


  test "example view code renders example markup" do
    assert_equal EXAMPLE_MARKUP, Context.new(roles).instance_eval(EXAMPLE_COMPILED.source_body)
  end

  test "compiled source is legible and transparent" do
    ctx, fragment = simple_tree_for(roles)
    assert_equal EXAMPLE_COMPILED.source_body, ExpressTemplates.compile(&fragment)
  end

  test "rendered component matches desired markup" do
    ExpressTemplates::Markup::Tag.formatted do
      ctx, fragment = simple_tree_for(roles)
      assert_equal EXAMPLE_MARKUP, ExpressTemplates.render(ctx, &fragment)
    end
  end

end
