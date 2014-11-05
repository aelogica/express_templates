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

      emits -> {
        table(my[:id]) {
          thead {
            tr {
              columns.each do |column|
                th.send(column.name) {
                  column.title
                }
              end
            }
          }
          tbody {
            for_each(my[:id]) {

              tr(id: -> {"item-#{item.id}"},
                 class: my[:id].to_s.singularize) {

                columns.each do |column|
                  td(class: column.name) {
                    column.format(:item)
                  }
                end
              }
            }
          }
        }
      }

      def wrap_for_stack_trace(body)
        "ExpressTemplates::Components::TableFor.render_in(self) {\n#{body}\n}"
      end

      def compile
        wrap_for_stack_trace(lookup(:markup))
      end

      def self.render_in(context, &view_code)
        context.instance_eval(&view_code)
      end

      class Column
        attr :name, :options
        def initialize(name, options = {})
          @name = name
          @options = options
          @formatter = options[:formatter]
        end

        def format(item_name)
          if @formatter.nil?
            "\#\{#{item_name}.#{name}\}"
          elsif @formatter.kind_of?(Proc)
            "\#\{(#{@formatter.source}).call(#{item_name}.#{name})\}"
          end
        end

        def title
          @name.to_s.try(:titleize)
        end
      end

    end

  end
end