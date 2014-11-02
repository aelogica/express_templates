module ExpressTemplates
  module Components
    # Create an html table from a collection of data.
    #
    # Typically this will be a collection of models
    # of the same type.  Each member of the collection must
    # respond to the column names provided.
    #
    # Example:
    #
    # ```ruby
    # table_for(:people) do |t|
    #   t.column :name
    #   t.column :email
    #   t.column :phone
    # end
    # ```
    #
    # This assumes that a @people variable will exist in the
    # view and that it will be a collection whose members respond to
    # :name, :email, and :phone
    #
    # This will result in markup like the following:
    #
    #     <table id="people">
    #       <thead>
    #         <tr>
    #           <th class="name">Name</th>
    #           <th class="email">Email</th>
    #           <th class="phone">Phone</th>
    #         </tr>
    #       </thead>
    #       <tbody>
    #         <tr id="person-1">
    #           <td class="name">Steven Talcott Smith</td>
    #           <td class="email">steve@aelogica.com</td>
    #           <td class="phone">415-555-1212</td>
    #         </tr>
    #       </tbody>
    #     </table>
    #
    class TableFor < Base
      include Capabilities::Configurable
      include Capabilities::Building

      def initialize(*args)
        super(*args)
        yield(self) if block_given?
      end

      attr :columns

      def column(name, options = {})
        @columns ||= []
        @columns << Column.new(name, options)
      end

      helper(:format_header) { |name| name.to_s.titleize }


      def view_code_for_cells
        collection_name = @options[:id].to_s
        item_name = collection_name.singularize
        columns.map do |column|
          %Q("      <td class="#{column.name}">#{column.format(item_name)}</td>\\n")
        end.join("+\n")
      end

      def view_code_for_headers
        binding.pry
        columns.map do |column|
          %Q("      <th class="#{column.name}">#{column.header}</th>\\n")
        end.join("+\n")
      end

      def wrap_for_stack_trace(body)
        "ExpressTemplates::Components::TableFor.render_in(self) {\n#{body}\n}"
      end

      def html(line)
        line.split("\n").map do |line|
          %Q("#{line.gsub(/\\"/, '\\\\\\"')}\\n")
        end.join("+\n")
      end

      def view_code 
        collection_name = @options[:id].to_s
        item_name = collection_name.singularize

        html(%Q(
<table id=\"#{collection_name}\">
  <thead>
    <tr>
)) +
        view_code_for_headers +
        html(%Q(
    </tr>
  </thead>
  <tbody>
)) +
" @#{collection_name}.map do |#{item_name}, index|" +
        html(%Q(
    <tr id=\"#{item_name}-\#{#{item_name}.try(:id)||index}\" class=\"#{item_name}\">
)) +
        view_code_for_cells +
        html(%Q(</tr>)) +
" end.join+" +
        html(%Q(
  </tbody>
</table>))
      end

      def compile
        wrap_for_stack_trace(view_code)
      end

      def self.render_in(context, &view_code)
        context.instance_eval(&view_code)
      end

      # def self.render_table_header(columns, options)
      #   _wrap_it(nil, wrapper: :head) do |c|
      #     columns.map do |column_name|
      #       eval
      #     end
      #   end
      # end

      # def self.render_table(context, collection_name, columns)
      #   collection = context.instance_eval("@#{collection_name}")
      #   ctx = context.instance_eval("binding")
      #   ctx.local_variable_set(:columns, columns)
      #   table 
      #   out = String.new

      #   head = _wrap_it(ctx, wrapper: :head) do |c|
      #     columns.map do |column_name|
      #       eval(c.send(:_lookup, :head_cell, column_name: column_name))
      #     end.join()
      #   end
      #   out
      # end

      class Column
        attr :name, :options
        def initialize(name, options = {})
          @name = name
          @options = options
        end

        def format(item_name)
          return "#{item_name}.#{name}"
        end

        def header
          @name.to_s.try(:titleize)
        end
      end

    end

  end
end