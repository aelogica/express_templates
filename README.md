# ExpressTemplates

Provides a DSL for HTML templates using a declarative style of Ruby as an alternative to Erb or HAML.

## Usage

Add this to your gemfile:

    gem 'express_templates'

Rename your application.html.erb to application.html.et.

Change your template to look like this.

    html(lang: "en") {
      head {
        meta charset: 'utf-8'
        meta name: 'viewport', content: "width=device-width, initial-scale=1.0"
        title {
          content_for(:title)
        }
        stylesheet_link_tag "application", media: 'all', 'data-turbolinks-track' => true
        csrf_meta_tags
      }
      body {
        yield
        javascript_include_tag "application"
      }
    }

Everything should work as you would expect.

Set your editor syntax for .et files to Ruby.

You will now have also be able to utilize components which are found with documentation and examples in <tt>ExpressTemplates::Components<tt>.

## History

To understand ExpressTemplates, you must first understand the standard tools of ERB and Haml which have been with us for quite some time.

<img src="https://raw.githubusercontent.com/aelogica/express_templates/master/diagrams/diagram_haml_erb.png" title="Diagram depciting Haml/Erb" style="align: center;">

Both of these provide a language for embedding other languages.  Erb embeds Ruby between <% %> style tags.  This is similar to the way we worked with PHP and for those who can remember "embedded Perl" in 1990s.  Erb places no constraints on either the text into which the Ruby is embedded, nor on the Ruby which may be placed within the delimiters which comprise Erb's simple grammar.

Haml introduced a number of innovations or improvements upon Erb.  Through Haml's use of significant whitespace and indentation, it ensures well-formed markup.  This noticably slows template compilation, however, due to caching it generally goes unnoticed.  Haml added better support for mixing grammars in a single file as is common practice with Javascript.  Haml introduced abbreviated methods for specifying CSS classes and HTML entity attribute values with the result of generally cleaning up view code.

Both Haml and Erb compile down to Ruby code which must be eval()'d in a View Context as per the interface required by Rails' ActionView.

## Expansion

ExpressTemplates introduces an earlier step in this process, "expansion", which may be likened to a kind of macro system.  This is introduced to facilitate reusable view components in the form of normal object-oriented Ruby classes.

<img src="https://raw.githubusercontent.com/aelogica/express_templates/master/diagrams/diagram_express_templates.png" title="Diagram depciting Haml/Erb" style="align: center;">

## Constraints - Important!

ExpressTemplates imposes some constraints.  The most important constraint is that your view templates must be declaritive in syntax and style.  Declaritve code is easier to read and reason about.  It also requires fewer tests since declarative code is build on presumably well-tested primitives.

With ExpressTemplates, one *must not* simply introduce conditional logic or iterators anywhere one feels like it in template code.  All logic *must* be encapsulated in components.  Strange things will happen if you try to put logic in the template or a template fragment.

If you have been around long enough to see a few Rails codebases grow out of control, and you have had to manage or watch the efforts of less-experienced developers closely, you know that one of the major causes of trouble and wasted effort is copy-and-paste code and logic errors in the view.  Another common problem is the "blank slate" issue wherein every view must be constructed new with little chance for proper reuse of code.  Diligent use of partials and helpers can do much to DRY up view code but deciding where to put them or how to share them between projects can be difficult.  Rarely is view logic tested except in integration.

ExpressTemplates only enforces what is already considered a best practice by many, while introducing new possilibities for well-ordered UX libraries similar to what developers working with commercial frameworks for desktop operating systems or mobile devices enjoy.

## Block Structure

ExpressTemplates use Ruby's block structure and execution order to indicate parent-child relationships and to build the tree structure that ultimately results in nodes in the DOM.

Example:

    ul {
      li { "one" }
      li "two"
      li %Q(#{@three})
    }

Let us suppose that an @three variable exists in the view context with the value "three".  This would yield the following markup:

    <ul><li>one</li><li>two</li><li>three</li>

yield and local variables which we may expect to be available in a ViewContext are also wrapped for evaluation later.

## Components

Given the constraint that logic must not go in the template, where does one put it?  The answer is we make a component!

ExpressTemplates provide a framework for construction of components by encapsulating common logic patterns found in view code into Capabilities which Components may include.  These Capabilities form a DSL which allows Components to be built in a declarative fashion.  This makes them "low-cost" entities to construct in terms of developer time.

A common need is for a list items such as in the above example to be generated from a collection or array of data.   Let us suppose we expect the view context to have:

    @list = %w(one two three)

We can make a simple component like so:

    class ListComponent < ExpressTemplates::Components::Base
      emits inner: -> {
                        li {
                          item
                        }
                      },
            outer: -> {
                        ul {
                          _yield
                        }
                      }

      for_each -> { @list }, emit: :inner

      wrap_with :outer
    end

This would be used in a view template just as if it were a tag, like so:

    div.active {
      list_component
    }

Now when the template renders, it will yield:

    <div class="active"><ul><li>one</li><li>two</li><li>three</li></ul></div>

## Background

ExpressTemplates is a key part of the AppExpress platform at [appexpress.io](http://appexpress.io).

This project rocks and uses MIT-LICENSE.
