capabilities = Dir.glob(File.join(File.dirname(__FILE__), 'capabilities', '*.rb'))
capabilities.each {|capability| require capability}

module ExpressTemplates
  # Components provide self-contained reusable view code meant to be shared
  # within a project or across many projects through a library of components
  #
  # Components gain their functionality through inclusion of Capabilities.
  #
  # Most Components are descendents of Components::Base.
  #
  module Components

    # Components::Base is the base class for ExpressTemplates view components.
    #
    # View components are available as macros in ExpressTemplates and may be
    # used to encapsulate common view patterns, behavior and functionality in
    # reusable classes that can be shared within and across projects.
    #
    # Components intended to provide a base framework for a library of reusable
    # components to cut development time across a multitude of projects.
    #
    # Components gain their functionality through including Capabilities.
    #
    # Example capabilities include:
    #
    # * Managing related ExpressTemplate fragments
    # * Compiling template fragments for evaluation in a View Context
    # * Specifying rendering logic to be executed in the View Context
    # * Potentially referencing external assets that may be required
    #   for the component to work.
    #
    # Components::Base includes the following capabilities:
    #
    # * Capabilities::Templating
    # * Capabilities::Rendering
    # * Capabilities::Wrapping
    # * Capabilities::Iterating
    #
    class Base < Arbre::Component
      include Capabilities::Templating
      include Capabilities::Rendering
      include Capabilities::Wrapping
      include Capabilities::Iterating
    end

  end
end
