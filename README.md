# ExpressTemplates

Provides a macro-ish DSL for use in constructing html templates in plain Ruby as an alternative to Erb or HAML.

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

### How It Works

ExpressTemplates works via a good-enough stand in for a true macro system in Ruby which would make this type of thing considerably easier.

Basically, we use these "macros" and Ruby's block structure to build up a tree of components corresponding to the HTML structure of a document fragment.  Each HTML5 tag is a Component available in the form of a macro.  Unrecognized identifiers are wrapped for later evaluation, presumably in a ViewContext.

yield and local variables which we may expect to be available in a ViewContext are also wrapped for evaluation later.

Templates are first "expanded", then "compiled" and then finally "rendered."

Expanding results in a tree of Component like objects which have children and respond to #compile().  The result of #compile on a component is a Ruby code fragment which may be evaluated in a ViewContext to produce markup.  Compiling is similar to what HAML or Erb does.

## Background

The bondage of HAML is unnecessary.  The clutter of Erb is unsightly.

I generally prefer "one syntax per file" for reasons of cognative load and maintainability.

The introduction of an macro-like pre-processing step yielding a tree of Components as described above allows us to implement higher-level components which inherit behavior via normal OO Ruby.  This points the way to a UX framework and component library that will play nice with Rails caching and conventions.

ExpressTemplates form part of the AppExpress platform at [appexpress.io](http://appexpress.io).

This project rocks and uses MIT-LICENSE.
