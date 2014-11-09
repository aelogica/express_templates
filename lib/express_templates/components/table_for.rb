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
    #   t.column :hourly_rate, header: "Rate",
    #                          formatter: -> (amount) {'$%0.2f' % amount rescue 'N/A'}
    # end
    # ```
    #
    # This assumes that a @people variable will exist in the
    # view and that it will be a collection whose members respond to
    # :name, :email, :phone, :hourly_rate
    #
    # This will result in markup like the following:
    #
    #     <table id="people">
    #       <thead>
    #         <tr>
    #           <th class="name">Name</th>
    #           <th class="email">Email</th>
    #           <th class="phone">Phone</th>
    #           <th class="hourly_rate">Rate</th>
    #         </tr>
    #       </thead>
    #       <tbody>
    #         <tr id="person-1">
    #           <td class="name">Steven Talcott Smith</td>
    #           <td class="email">steve@aelogica.com</td>
    #           <td class="phone">415-555-1212</td>
    #           <td class="hourly_rate">$250.00</td>
    #         </tr>
    #       </tbody>
    #     </table>
    #
    # Note that column options include :formatter and :header.
    #
    # :formatter may be a stabby lambda which is passed the value to be formatted.
    #
    # :header may be either a string
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

      class Column
        attr :name, :options
        def initialize(name, options = {})
          @name = name
          @options = options
          @formatter = options[:formatter]
          @header = options[:header]
        end

        def format(item_name)
          if @formatter.nil?
            "\#\{#{item_name}.#{name}\}"
          elsif @formatter.kind_of?(Proc)
            "\#\{(#{@formatter.source}).call(#{item_name}.#{name})\}"
          end
        end

        def title
          case
          when @header.nil?
            @name.to_s.try(:titleize)
          when @header.kind_of?(String)
            @header
          when @header.kind_of?(Proc)
            "{{(#{@header.source}).call(#{@name})}}"
          end
        end
      end

    end

  end
end