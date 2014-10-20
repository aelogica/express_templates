module ExpressTemplates
  module Components
    module Capabilities
      #
      # Adds the capability to iterate over a collection repeating a markup
      # fragment for each member.
      #
      # Example:
      #
      #   class ParagraphsComponent < ExpressTemplates::Components::Base
      #
      #     emits -> { p { item } }     # item is the default local variable name
      #
      #     for_each -> { paragraphs }  # evaluated in view context
      #
      #   end
      #
      # Must specify an <tt>iterator</tt> either as a proc to be evaluated in the
      # view context or else as a variable name in the form of a symbol which is
      # assumed to be available in the view context.
      #
      # Provides:
      #
      # * Iterating::ClassMethods (for_each)
      #
      module Iterating
        def self.included(base)
          base.class_eval do
            extend ClassMethods
          end
        end

        module ClassMethods
          # Sets the component up to use iterating logic to reproduce a fragment
          # for a collection.
          #
          # Parameters include an iterator that may be :@variable assumed to be
          # available in context or a proc that when evaluated in the context
          # should return a collection.
          #
          # An <tt>:emit</tt> option may specify a fragment to emit.
          # Defaults to <tt>:markup</tt>
          #
          # An <tt>:as</tt> option specifies the local variable name for each
          # item in the collection for use in the fragment.  Defaults to: <tt>item</tt>
          #
          # An <tt>:empty</tt> option specifies a fragment to use for the
          # empty state when the iterator returns an empty collection.
          def for_each(iterator, as: :item, emit: :markup, empty: nil)
            if iterator.kind_of?(Symbol)
              var_name = iterator.to_s.gsub(/^@/,'').singularize.to_sym
            else
              var_name = as
            end
            using_logic do |component, options|
              collection = if iterator.kind_of?(Proc)
                if iterator.arity.eql?(1)
                  instance_exec(options, &iterator)
                else
                  instance_exec &iterator
                end
              else
                eval(iterator.to_s)
              end
              if collection.empty?
                component[empty]
              else
                collection.map do |item|
                  b = binding
                  b.local_variable_set(var_name, item)
                  b.eval(component[emit], __FILE__)
                end.join
              end
            end
          end
        end
      end
    end
  end
end
