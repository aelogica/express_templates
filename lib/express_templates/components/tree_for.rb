module ExpressTemplates
  module Components
    module Presenters
      #
      # Create an html <tt>table</tt> or <tt>ol</tt> (ordered list) for
      # a model object representing a tree of similar objects.
      #
      # The objects must respond to <tt>:children</tt>.
      #
      # The block is passed a NodeBuilder which may accept field names.
      #
      # Example:
      #
      # ```ruby
      # tree_for(:roles) { |role|
      #   role.name
      # }
      # ```
      #
      # If the view has an @roles variable with a Role having children,
      # this will turn into markup such as the following:
      #
      #     <ul id="roles" class="roles tree">
      #       <li>SuperAdmin
      #         <ul>
      #           <li>Admin
      #             <ul>
      #               <li>Publisher
      #                 <ul>
      #                    <li>Author</li>
      #                 </ul>
      #               </li>
      #               <li>Auditor</li>
      #             </ul>
      #           </li>
      #         </ul>
      #       </li>
      #     </ul>
      #

      class TreeFor < Configurable

        tag :ul

        has_attributes :class => 'tree'
        has_option :root, "Root of the tree.  Defaults to collection with the same as the id.", type: :proc

        contains -> (&customize_block) {
          @customize_block = customize_block
          list_items(root_node)
        }

        before_build -> {
          add_class config[:id]
        }

        def root_node
          if config[:root] && config[:root].respond_to?(:call)
            config[:root].call
          else
            send(config[:id])
          end
        end

        def list_items(nodes)
          nodes.each do |node|
            list_item(node)
          end
        end

        def list_item(node)
          li {
            if @customize_block
              @customize_block.call(node)
            else
              text_node "#{node.name}#{"\n" if node.children.any?}"
            end
            if node.children.any?
              ul {
                list_items(node.children)
              }
            end
          }
        end
      end
    end
  end
end