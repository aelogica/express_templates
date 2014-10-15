module ExpressTemplates
  module Markup
    # wrap locals and helpers for evaluation during render
    class Wrapper

      attr_accessor :name, :args

      def initialize(name, *args, &block)
        @name = name
        @args = args
        @block_src = block ? block.source : nil
      end

      def compile
        # insure nils do not blow up view
        %Q("\#\{#{_compile}\}")
      end

      def to_template
        _compile
      end

      def children
        []
      end

      private
        def _compile
          string = "#{name}"

          if !@args.empty?
            args_string = args.slice(0..-2).map(&:inspect).map(&:_remove_double_braces).join(', ')
            last_arg = ''
            if args.last.is_a?(Hash) # expand a hash
              unless args.last.empty?
                # This approach has limitations - will only work on structures of
                # immediate values
                last_arg = args.last.inspect.match(/^\{(.*)\}$/)[1]
                last_arg.gsub!(/:(\w+)=>/, '\1: ') # use ruby 2 hash syntax
              else
                last_arg = "{}" # empty hash
              end
            else
              last_arg = args.last.inspect._remove_double_braces
            end
            args_string << (args_string.empty? ? last_arg : ", #{last_arg}")
            string << "(#{args_string})"
          end

          if @block_src
            string << " #{@block_src}"
          end

          return string
        end
    end
  end
end

class String
  def _remove_double_braces
    match(/\{\{(.*)\}\}/).try(:[], 1) || self
  end
end
