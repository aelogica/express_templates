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

  EXAMPLE_MARKUP = <<-HTML
<ul id="roles" class="roles tree">
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