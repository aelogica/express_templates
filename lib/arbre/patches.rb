module Arbre
  class Context
    def resource
      helpers.resource
    end
  end

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

    def possible_route_proxy(name)
      if helpers.controller.class.parent &&
        helpers.respond_to?(namespace = helpers.controller.class.parent.to_s.underscore)
        if (route_proxy = helpers.send(namespace)).respond_to?(name)
          return route_proxy
        end
      end
      return nil
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
      elsif assigns && assigns.has_key?(name.to_sym)
        assigns[name.to_sym]
      elsif helpers.respond_to?(name)
        helper_method(name, *args, &block)
      elsif route_proxy = possible_route_proxy(name)
        route_proxy.send(name, *args, &block)
      else
        super
      end
    end

    # In order to not pollute our templates with helpers. prefixed
    # everywhere we want to try to distinguish helpers that are almost
    # always used as parameters to other methods such as path helpers
    # and not add them as elements
    def helper_method(name, *args, &block)
      if name.match /_path$/
        helpers.send(name, *args, &block)
      elsif (const_get([name, 'engine'].join('/').classify) rescue nil)
        helpers.send(name, *args, &block)
      else
        current_arbre_element.add_child helpers.send(name, *args, &block)
      end
    end

  end

end