# Gara (柄)

Provides a functional handle to nokogiri (鋸) for use in constructing html templates in plain Ruby as an alternative to Erb or HAML.

## Usage

Add this to your gemfile:

    gem 'gara'

Rename your application.html.erb to application.html.gara.

Change your template to look like this.

    html lang: "en" {
      head {
        meta charset: 'utf-8'
        meta name: 'viewport', content: "width=device-width, initial-scale=1.0"
        title { yield(:title) || '' }
        stylesheet_link_tag "application", media: all, 'data-turbolinks-track' => true
        javascript_include_tag 'application', 'data-turbolinks-track' => true
        csrf_meta_tags
      }
      body {
        yield
        javascript_include_tag "application"
      }
    }

Everything should work as you would expect.

Set your editor syntax for .gara files to Ruby.

## Background

The motivation for this gem is simple.  The bondage of HAML is unnecessary.  The clutter of Erb is unsightly.

I want to reduce cognative load, increase development speed and reduce errors.  I have observed much time is spent in view construction and many errors creep in here.  The seemingly minor irritation of having multiple syntaxes present in a single file contributes to problems.

I want one syntax per file.  With a little imagination Ruby can map to HTML easily using its block structure.  This facilitates construction of an internal DSL that is "Just Ruby."

Ultimately my objective with Gara is to get away from writing HTML directly and to use Gara as a substrate for building pages out of higher-level, reusable components which include not only DOM elements but also behaviors.  This is a key aspect of the AppExpress platform at [appexpress.io](http://appexpress.io).

This project rocks and uses MIT-LICENSE.
