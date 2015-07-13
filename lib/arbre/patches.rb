module Arbre
  class Element

    module BuilderMethods

      # we do not want to check the arity of the
      # block in express templates because components
      # are expected to be able to contain other components or template code
      # without use of a builder style syntax
      def build_tag(klass, *args, &block)
        tag = klass.new(arbre_context)
        tag.parent = current_arbre_element

        with_current_arbre_element tag do
          tag.build(*args, &block)
        end

        tag
      end
    end

    # Implements the method lookup chain. When you call a method that
    # doesn't exist, we:
    #
    #  1. Try to call the method on the current DOM context
    #  2. Return an assigned variable of the same name
    #  3. Call the method on the helper object
    #  4. Call super
    #
    def method_missing(name, *args, &block)
      if current_arbre_element.respond_to?(name)
        current_arbre_element.send name, *args, &block
      elsif assigns && assigns.has_key?(name)
        assigns[name]
      elsif helpers.respond_to?(name)
        current_arbre_element.add_child helpers.send(name, *args, &block)
      else
        super
      end
    end

  end
end