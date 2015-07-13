module ExpressTemplates
  module Components
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
    # tree_for(:roles) {
    #   "{{role.name}}"
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
      emits {
        ul {
          li {
            "fix me"
          }
        }
      }
    end
  end
end