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

This project rocks and uses MIT-LICENSE.
