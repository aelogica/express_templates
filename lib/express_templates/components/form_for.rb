module ExpressTemplates
  module Components
    #
    # Create an html <tt>form</tt> for a model object.
    #
    # Example:
    #
    # ````ruby
    # form_for(:people) do |f|
    #   f.text_field  :name
    #   f.email_field :email
    #   f.phone_field :phone, wrapper_class: 'field phone'
    #   f.submit 'Save'
    # end
    # ````
    #
    # This assumes that @people variable will exist in the
    # view and that it will be a collection whose members respond to :name, :email etc.
    #
    # This will result in markup like the following:
    #
    # ````
    # <form action="/people" method="post">
    #   <div style="display:none">
    #     <input name="utf8" type="hidden" value="✓">
    #     <input type="hidden" name="_method" value="post">
    #     <input type="hidden" name="authenticity_token" value="5ZDztTe1N4tc03QSjmMdSVqAw==">
    #   </div>
    #
    #   <div>
    #     <label for="person_name">Name</label>
    #     <input type="text" name="person[name]" id="person_name" />
    #   </div>
    #
    #   <div>
    #     <label for="person_email">Email</label>
    #     <input type="email" name="person[email]" id="person_email" />
    #   </div>
    #
    #   <div class="field phone">
    #     <label for="person_phone">Phone</label>
    #     <input type="tel" name="person[phone]" id="person_phone" />
    #   </div>
    #
    #   <div>
    #     <input type="submit" name="commit" value="Save" />
    #   </div>
    # </form>
    # ````
    #
    # As seen above, each field is accompanied by a label and is wrapped by a div.
    # The div can be further styled by adding css classes to it via the `wrapper_class` option.
    #
    # Example:
    #
    # ````ruby
    # form_for(:posts) do
    #   f.text_field :title, wrapped_class: 'string optional'
    # end
    #
    # Will result to generating HTML like so:
    #
    # ````
    #   ...
    #   <div class='string optional'>
    #     <label for='post_title'>Title</label>
    #     <input type="text" name="post[title]" id="post_title" />
    #   </div>
    #   ...
    # ````
    #
    # In addition to this, label text can also be customized using the `label` option:
    #
    # ````ruby
    #   f.email_field :email_address, label: 'Your Email'
    # ````
    #
    # Compiles to;
    # ````
    #   <label for='user_email'>Your Email</label>
    #   <input type='email' name='user[email]' id='user_email' />
    # ````
    class FormFor < Base
      include Capabilities::Configurable
      include Capabilities::Building

      def initialize(*args)
        # TODO: need a better way to select the form options
        @form_options = args.select { |x| x.is_a?(Hash) }
        super(*args)
        _process_args!(args) # from Configurable
        yield(self) if block_given?
      end

      attr :fields

      # Express Templates uses Rails' form helpers to generate the fields with labels
      #
      # Example:
      #
      # ````ruby
      # form_for(:people) do |f|
      #   f.phone_field :phone
      # end
      # ````
      #
      # This will precompile as
      #
      # ````ruby
      #    ...
      #    phone_field_tag :phone, @people.phone, {}
      #    ...
      # ````
      #
      # Fields can also have custom classes via the `class` option:
      #
      # Example:
      #
      # ````ruby
      #    f.url_field :website_url, class: 'url-string'
      # ````
      #
      # Compiles to:
      #
      # ````
      #    <input type='url' name='post[website_url]' id='post_website_url' class='url-string' />
      # ````
      #
      # You can also add in the basic options supported by the
      # phone_field_tag [here](http://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html#method-i-phone_field_tag)
      #
      # This applies to all the other '_field_tags' listed
      # [here](http://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html)
      #
      #
      # = Fields
      # ````ruby
      # f.text_field :name
      # #   <div>
      # #    <label for="person_name">Name</label>
      # #    <input type="text" name="person[name]" id="person_name" />
      # #   </div>
      #
      # f.text_field :name, label: 'post title'
      # #   <div>
      # #    <label for="person_name">Post Title</label>
      # #    <input type="text" name="person[name]" id="person_name" />
      # #   </div>
      #
      # f.text_field :name, class: 'string'
      # #   <div>
      # #    <label for="person_name">Name</label>
      # #    <input type="text" name="person[name]" class='string' id="person_name" />
      # #   </div>
      #
      # f.text_field :name, wrapper_class: 'field input'
      # #   <div class="field input">
      # #    <label for="person_name">Name</label>
      # #    <input type="text" name="person[name]" id="person_name" />
      # #   </div>
      #
      # ````
      %w(email phone text password color date datetime
        datetime_local hidden number range
        search telephone time url week).each do |type|
        define_method("#{type}_field") do |name, options={}|
          @fields ||= []
          @fields << Field.new(name, options, type.to_sym)
        end
      end

      # ==== Examples
      #   f.select :gender, ['Male', 'Female'], selected: 'Male'
      #   # <div>
      #   #   <label for="person_gender">Gender</label>
      #   #   <select id="person_gender" name="person[gender]">
      #   #     <option selected="selected" value="Male">Male</option>
      #   #     <option selected="selected" value="Female">Female</option>
      #   #   </select>
      #   # </div>
      #   f.select :name, options_from_collection_for_select(@people, "id", "name")
      #   # <div>
      #   #   <label for="person_name">Name</label>
      #   #   <select id="people_name" name="people[name]"><option value="1">David</option></select>
      #   # </div>
      #
      def select(name, select_options, options = {})
        @fields ||= []
        @fields << Select.new(name, options.merge!(select_options: select_options))
      end

      # ==== Examples
      #   f.radio :card, [[1, 'One'], [2, 'Two']], :first, :last
      #   # <div>
      #   #   <label class="radio" for="user_age_1"><input type="radio" value="1" name="user[age]" id="user_age_1">One</label>
      #   #   <label class="radio" for="user_age_2"><input type="radio" value="2" name="user[age]" id="user_age_2">Two</label>
      #   # </div>
      #
      def radio(name, collection, value_method, text_method, options = {})
        @fields ||= []
        @fields << Radio.new(name, options.merge!(collection: collection, value_method: value_method, text_method: text_method))
      end

      # ==== Examples
      #   f.checkbox :age, [[1, 'One'], [2, 'Two']], :first, :last
      #   # <div>
      #   #   <label class="checkbox" for="user_age_1">
      #   #     <input type="checkbox" value="1" name="user[age][]" id="user_age_1">
      #   #     "One"
      #   #   </label>
      #   #   <label>
      #   #     <input type="checkbox" value="2" name="user[age][]" id="user_age_2">
      #   #     "Two"
      #   #   </label>
      #   # </div>
      #
      def checkbox(name, collection, value_method, text_method, options = {})
        @fields ||= []
        @fields << Checkbox.new(name, options.merge!(collection: collection, value_method: value_method, text_method: text_method))
      end

      # ==== Examples
      #   f.text_area :name
      #   # <div>
      #   #   <label for="user_name">Name</label>
      #   #   <textarea name="user[name]" id="user_name" >
      #   # </div>
      #   f.text_area :name, label: 'post title'
      #   # <div>
      #   #   <label for="user_name">Post Title</label>
      #   #   <textarea name="user[name]" id="user_name" >
      #   # </div>
      #   f.text_area :name, wrapper_class: 'field input'
      #   # <div class="field input">
      #   #   <label for="user_name">Name</label>
      #   #   <textarea name="user[name]" id="user_name" >
      #   # </div>
      #   f.text_area :name, class: 'string'
      #   # <div>
      #   #   <label for="user_name>Name</label>
      #   #   <textarea name="user[name] id="user_name" class="string" >
      #   # </div>
      #
      def text_area(name, options = {})
        @fields ||= []
        @fields << TextArea.new(name, options)
      end

      # ==== Examples
      #   f.submit "Save Changes"
      #   # <div>
      #   #   <input type="submit" name="commit" value="Save Changes" />
      #   # </div>
      #
      def submit(name = 'Submit Changes', options = {})
        @fields ||=[]
        @fields << Field.new(name, options, :submit)
      end

      emits -> {
        resource_name = my[:id].to_s
        form_options = @form_options.first
        form_method = form_options.delete :method if form_options

        form_method = if form_method == :put
                        :patch
                      else
                        form_options.present? ?  form_options[:method] : :post
                      end

        form_action  = if form_method == :patch
                       %Q(/#{resource_name.pluralize}/{{@#{resource_name}.id}})
                       else
                       %Q(/#{resource_name.pluralize})
                     end

        form_args = {action: form_action, method: :post}
        form_args.merge!(form_options) unless form_options.nil?

        form(form_args) {
          form_rails_support form_method
          fields.each do |field|
            field_name = field.name
            field_type = field.type.to_s
            resource_field_name = "#{resource_name.singularize}[#{field_name}]"
            label_name = "#{resource_name.singularize}_#{field_name}"
            field_label = field.label || field_name.to_s.capitalize

            div(class: field.wrapper_class) {
              if field_type == 'select'
                label_tag(label_name, field_label)
                select_tag(resource_field_name, field.options_html, field.options)
              elsif field_type == 'radio'
                collection_radio_buttons(my[:id], field_name, field.collection,
                                         field.value_method, field.text_method, field.options) do |b|
                  b.label(class: 'radio') { b.radio_button + b.text }
                end
              elsif field_type == 'checkbox'
                collection_check_boxes(my[:id], field_name, field.collection,
                                       field.value_method, field.text_method, field.options) do |b|
                  b.label(class: 'checkbox') { b.check_box + b.text }
                end
              elsif field_type == 'submit'
                submit_tag(field_name, field.options)
              else
                label_tag(label_name, field_label) unless field_type == 'hidden'
                args = [resource_field_name, "{{@#{resource_name.singularize}.#{field_name}}}", field.options]
                tag_string = if field_type == 'text_area'
                                 'text_area_tag'
                               else
                                 "#{field_type}_field_tag"
                               end

                self.send(tag_string.to_sym, *args)
              end
            }
          end
        }
      }

      def wrap_for_stack_trace(body)
        "ExpressTemplates::Components::FormFor.render_in(self) {\n#{body}\n}"
      end

      def compile
        wrap_for_stack_trace(lookup(:markup))
      end

      class Field
        attr :name, :options, :label, :type, :wrapper_class
        def initialize(name, options = {}, type=:text)
          @name = name
          @options = options
          @label = options[:label]
          @wrapper_class = @options.delete(:wrapper_class)
          @type = type
        end
      end

      class TextArea < Field
        def initialize(name, options={})
          super(name, options, :text_area)
        end
      end

      class Radio < Field
        attr :collection, :value_method, :text_method
        def initialize(name, options = {})
          @collection = options.delete :collection
          @value_method = options.delete :value_method
          @text_method = options.delete :text_method
          super(name, options, :radio)
        end
      end

      class Checkbox < Radio
        def initialize(name, options = {})
          super(name, options)
          @type = :checkbox
        end
      end

      class Select < Field
        attr :choices
        def initialize(name, options = {})
          @choices = options.delete :select_options
          @selected = options.delete :selected
          super(name, options, :select)
        end

        def options_html
          choice_string = ""
          if @choices.is_a?(String)
            choice_string = @choices
          else
            @choices.map do |choice|
              selected_string = (@selected != nil && choice == @selected) ? 'selected=selected' : nil
              choice_string << "<option #{selected_string}>#{choice}</option>"
            end
            "{{'#{choice_string}'.html_safe}}"
          end
        end
      end
    end
  end
end
