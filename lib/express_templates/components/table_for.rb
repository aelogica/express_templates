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
        _process_args!(args) # from Configurable
        yield(self) if block_given?
      end

      attr :columns

      def column(name, options = {})
        @columns ||= []
        @columns << Column.new(name, options)
      end

      helper(:format_header) { |name| name.to_s.titleize }

      def self.for_each(collection_name, &block)
        %Q('@#{collection_name}.map { #{ yield()} }.join("\\\n")')
      end

      @helpers ||= {}
      @helpers[:for_each] = method(:for_each)

      emits -> {
        table(my[:id]) {
          thead {
            tr {
              for_each(:columns) { |column|
                th.send(column.name) {
                  column.title
                }
              }
            }
          }
          # tbody {
          #   for_each_view_collection(my[:collection]) { |item|
          #     tr {
          #       for_each(:column) { |column|
          #         td(item.dom_id, class: item.type) {
          #           column.format(item)
          #         }
          #       }
          #     }
          #   }
          # }
        }
      }

      def wrap_for_stack_trace(body)
        "ExpressTemplates::Components::TableFor.render_in(self) {\n#{body}\n}"
      end

      def compile
        # binding.pry
        wrap_for_stack_trace(lookup(:markup))
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