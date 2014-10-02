capabilities = Dir.glob(File.join(File.dirname(__FILE__), 'capabilities', '*.rb'))
capabilities.each {|capability| require capability}

module ExpressTemplates
  # Components provide self-contained reusable view code meant to be shared
  # within a project or across many projects through a library of components
  #
  # See <tt>Components::Base</tt> below for more infomation.
  #
  module Components

    # Components::Base is the base class for ExpressTemplates view components.
    #
    # View components are available as macros in ExpressTemplates and may be
    # used to encapsulate common view patterns, behavior and functionality in
    # reusable classes that can be shared within and across projects.
    #
    # Our intention here is to create a base framework for a library of reusable
    # components to cut development time across a multitude of projects.
    #
    # Components gain their functionality through including <tt>Capabilities</tt>.
    #
    # Example capabilities include:
    #
    #   * Storing ExpressTemplate fragments
    #   * Compiling into a template fragment for evaluation in a View Context
    #   * Specifying rendering logic to be executed in the View Context
    #   * Incorporating Javascript behaviors that execute in the page
    #
    class Base
      include ExpressTemplates::Macro
      include Capabilities::Templating
      include Capabilities::Rendering
      include Capabilities::Wrapping
      include Capabilities::Iterating

      def self.inherited(klass)
        ExpressTemplates::Expander.register_macros_for klass
      end

    end

  end
end
