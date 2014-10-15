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
              last_arg = _convert_hash_to_argument_string(args.last)
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

        def _convert_hash_to_argument_string(hash)
          use_hashrockets = hash.keys.any? {|key| key.to_s.match /-/}
          unless hash.empty?
            return hash.map do |key, value|
              s = if use_hashrockets
                if key.to_s.match /-/
                  "'#{key}' => "
                else
                  ":#{key} => "
                end
              else
                "#{key}: "
              end

              case
              when value.is_a?(String)
                s << '"'+value+'"'
              when value.is_a?(Hash)
                s << value.inspect
              when value.is_a?(Proc)
                s << "(-> #{value.source}).call"
              else
                s << value.inspect  # immediate values 1, 2.0, true etc
              end
              s
            end.join(", ")
          else
            "{}" # empty hash
          end
        end
    end
  end
end

class String
  def _remove_double_braces
    match(/\{\{(.*)\}\}/).try(:[], 1) || self
  end
end
