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
      tree_for(:roles) {
        role.name
      }
    }
  end


  test "simple_tree_for renders example markup" do
    assert_equal EXAMPLE_MARKUP, simple_tree_for.to_s
  end

end