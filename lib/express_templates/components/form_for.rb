module ExpressTemplates
  module Components
    #
    # Create an html <tt>form</tt> for a model object.
    #
    # Example:
    #
    # ```ruby
    # form_for(:people) do |t|
    #   t.text_field  :name
    #   t.email_field :email
    #   t.phone_field :phone
    # end
    # ```
    #
    class FormFor < Container
    end
  end
end