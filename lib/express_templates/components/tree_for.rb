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
    class TreeFor < Container
      def node_renderer
        return (-> (node, renderer) {
    ExpressTemplates::Indenter.for(:tree) do |ws, wsnl|
      "#{wsnl}<li>"+
      _yield +
      if node.children.any?
        ExpressTemplates::Indenter.for(:tree) do |ws, wsnl|
          "#{wsnl}<ul>" +
            node.children.map do |child|
              renderer.call(child, renderer)
            end.join +
          "#{wsnl}</ul>"
        end +
        "#{wsnl}</li>"
      else
        "</li>"
      end
    end
  }).source.sub(/\W_yield\W/, compile_children.lstrip)
      end

      def compile
        collection = if @options[:collection]
            "#{@options[:collection].source}.call()"
          else
            _variablize(@options[:id])
          end
        member = @options[:id].to_s.singularize
        return 'ExpressTemplates::Components::TreeFor.render_in(self) {
  node_renderer = '+node_renderer.gsub(/node/, member)+'
  ExpressTemplates::Indenter.for(:tree) do |ws, wsnl|
    "#{ws}<ul id=\"'+@options[:id]+'\" class=\"'+@options[:id]+' tree\">" +
      '+collection+'.map do |'+member+'|
        node_renderer.call('+member+', node_renderer)
      end.join +
    "#{wsnl}</ul>\n"
  end
}'
      end

      private
        def _variablize(sym)
          "@#{sym}"
        end
    end
  end
end