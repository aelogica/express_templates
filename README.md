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

Basically, we use these "macros" and Ruby's block structure to build up a tree of components corresponding to the HTML structure of a document fragment.  Each HTML5 tag is a component available in the form of a macro.  Unrecognized identifiers are wrapped for later evaluation, presumably in a ViewContext.

yield and local variables which we may expect to be available in a view context are also wrapped for evaluation later.

## Background

Sufficent motivation for this gem can be explained thusly:  The bondage of HAML is unnecessary.  The clutter of Erb is unsightly.

I generall prefer "one syntax per file" for reasons of cognative load and maintainability.

Ultimately my objective with ExpressTemplates is to get away from writing HTML directly and to use this as a substrate for building pages out of higher-level, reusable components which include not only DOM elements but also behaviors.

ExpressTemplates are part of the AppExpress platform at [appexpress.io](http://appexpress.io).

This project rocks and uses MIT-LICENSE.
