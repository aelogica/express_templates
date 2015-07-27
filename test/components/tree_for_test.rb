require 'test_helper'
require 'ostruct'

class TreeForTest < ActiveSupport::TestCase

  class Role
    attr :name, :children
    def initialize(name, children: [])
      @name = name
      @children = children
    end
  end

  def roles
    @roles ||= [Role.new('SuperAdmin', children:
          [Role.new('Admin', children:
            [Role.new('Publisher', children:
              [Role.new('Author')]),
             Role.new('Auditor')])])]
  end

  EXAMPLE_MARKUP = <<-HTML
<ul class="tree-for tree roles" id="roles">
  <li>
SuperAdmin
    <ul>
      <li>
Admin
        <ul>
          <li>
Publisher
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

  def assigns
    {roles: roles}
  end

  def simple_tree_for
    arbre {
      tree_for(:roles)
    }.to_s
  end

  test "tree_for renders correct markup with node.name as default" do
    assert_equal EXAMPLE_MARKUP, simple_tree_for
  end

  def custom_tree_for
    arbre {
      tree_for(:roles) { |node|
        text_node node.name.upcase
      }
    }
  end

  test "tree_for accepts block with custom content" do
    assert_match 'AUTHOR', custom_tree_for
  end

end