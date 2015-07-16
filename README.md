# ExpressTemplates

Provides a DSL for HTML templates using a declarative style of Ruby as an alternative to Erb or HAML.

Although originally we implemented our own DSL and used a code generation approach,
this gem now uses [ActiveAdmin's arbre](https://github.com/activeadmin/arbre).  Arbre is widely
used as part of ActiveAdmin, has a long history and many contributors and is conceptually much simpler.

## Usage

Add this to your gemfile:

```ruby
gem 'express_templates'
```

Rename your application.html.erb to application.html.et.

Change your template to look like this.

```ruby
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
    current_arbre_element.add_child yield
    javascript_include_tag "application"
  }
}
```

Everything should work as you would expect.

Set your editor syntax for .et files to Ruby.

You can now utilize components which are found with documentation and examples in <tt>ExpressTemplates::Components<tt>.

Components are the real strength of both arbre and express_templates.

express_templates now *is* arbre + some components + some conventions.  ExpressTemplates::Components::Base provides a little syntactic sugar in the form of the emits class method.

In terms of conventions, we use brace blocks { } to indicate html structure and do/end blocks to indicate control flow.

Control flow should only be used in Components.  This is currently not enforced but it will be in the future.

The purpose of express_templates is to provide a foundation for a library of reusable UX components which we can enhance for drag-and-drop style UX construction and template editing.


## Block Structure

ExpressTemplates use Ruby's block structure and execution order to indicate parent-child relationships and to build the tree structure that ultimately results in nodes in the DOM.

Example:

```ruby
ul {
  li { "one" }
  li "two"
  li %Q(#{@three})
}
```

Let us suppose that an @three variable exists in the view context with the value "three".  This would yield the following markup:

```html
<ul>
  <li>one</li>
  <li>two</li>
  <li>three</li>
</ul>
```

## Components

Given the constraint that logic must not go in the template, where does one put it?  The answer is we make a component!

ExpressTemplates provide a framework for construction of components by encapsulating common logic patterns found in view code into Capabilities which Components may include.  These Capabilities form a DSL which allows Components to be built in a declarative fashion.  This makes them "low-cost" entities to construct in terms of developer time.

A common need is for a list items such as in the above example to be generated from a collection or array of data.   Let us suppose we expect the view context to have:

```ruby
@list = %w(one two three)
```

We can make a simple component like so:

```ruby
class ListComponent < ExpressTemplates::Components::Base
  emits -> {
    ul {
      # assumes view provides list
      list.each do |item|
        li {
          item
        }
      end
    }
  }
end
```

This would be used in a view template just as if it were a tag, like so:

```ruby
div(class: "active") {
  list_component
}
```

Now when the template renders, it will yield:

```html
<div class="active">
  <ul>
    <li>one</li>
    <li>two</li>
    <li>three</li>
  </ul>
</div>
```

## Background

ExpressTemplates is a key part of the AppExpress platform at [appexpress.io](http://appexpress.io).

This project rocks and uses MIT-LICENSE.
