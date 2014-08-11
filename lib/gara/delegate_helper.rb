module Gara
  module DelegateHelper
    def define_delegate(method_name, on: nil, to: nil)
      on.module_eval <<-RUBY
        def #{method_name}(*args)
          #{to}.#{method_name}(*args) { yield if block_given? }
        end
      RUBY
    end
  end
end