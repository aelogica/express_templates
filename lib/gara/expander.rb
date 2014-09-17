module Gara
  class Expander

    def self.expand(template, source)
      new(template).expand(source).map(&:compile).join("+")
    end

    def initialize(template)
      @template = template
      @stack = [] ; @frame = -1
    end

    def expand(source=nil, &block)
      if source
        eval(source)
      else
        instance_eval &block
      end
    end

    # Search the component module space for a class corresponding to
    # the macro name
    def method_missing(name, *args)
      begin
        @stack.push [] ; @frame+=1;
        module_search_space = ["Gara::Components"]
        module_search_space.each do |space|
          begin
            if klass = "#{space}::#{name.to_s.titleize}".constantize
              @stack[@frame] << if block_given?
                  klass.new(*(args.push(*yield)))
                else
                  klass.new(*args)
                end
            end
            return @stack[@frame]
          rescue NameError => e
          end
        end
      ensure
        @frame-=1
      end
      super(name, *args)
    end
  end
end