require 'test_helper'
require 'haml'

class PerformanceTest < ActiveSupport::TestCase

  GARA_EXAMPLE =<<-RUBY
html(lang: "en") {
  head {
    meta charset: 'utf-8'
    meta name: 'viewport', content: "width=device-width, initial-scale=1.0"
    stylesheet_link_tag "application", media: 'all', 'data-turbolinks-track' => true
    csrf_meta_tags
  }
  body {
    h1 "Hello"
    p "Some text"
    javascript_include_tag "application"
  }
}
RUBY

  ERB_EXAMPLE = <<-ERB
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
<head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<%= stylesheet_link_tag 'application' %>
<%= csrf_meta_tags %>
</head>
<body>
<h1>Hello</h1>
<p>Some text</p>
<%= javascript_include_tag 'application' %>
</body>
</html>
ERB

  HAML_EXAMPLE = <<-HAML
%html{:xmlns => "http://www.w3.org/1999/xhtml", :lang => "en", 'xml:lang' => "en"}
  %head
    %meta{'http-equiv' => "Content-Type", 'content' => "text/html; charset=UTF-8"}
    %meta{ 'charset' => 'utf-8'}
    %meta{'name' => 'viewport', 'content' => 'width=device-width, initial-scale=1.0'}
    = stylesheet_link_tag 'application'
    = csrf_meta_tags
  %body
    %h1 Hello
    %p Some text
    = javascript_include_tag 'application'
HAML
  # class Context
    def javascript_include_tag(name, *args)
      %Q(<script data-turbolinks-track="true" src="/assets/#{name}.js"></script>)
    end

    def stylesheet_link_tag(name, *args)
      %Q(<link data-turbolinks-track="true" href="/assets/#{name}.css" media="all" rel="stylesheet" />)
    end
    def csrf_meta_tags
      %Q(<meta content="authenticity_token" name="csrf-param" />
<meta content="NF7iiBSErALM5A24Iw07wMH9e8rzxehE50Sv6iPYo98=" name="csrf-token" />
)
    end
  # end

  def time(count)
    start_time = Time.now
    1.upto(100) { yield }
    end_time = Time.now
    return end_time - start_time
  end

  test "performance is okay" do
    duration = time(100) { Gara.render(self, "#{GARA_EXAMPLE}") }
    assert_operator 1.0, :>, duration
  end

  test "performance no more than 3x slower than erubis" do
    eruby = Erubis::Eruby.new
    duration_erb = time(100) { eval(eruby.convert(ERB_EXAMPLE)) }
    duration_gara = time(100) { Gara.render(self, "#{GARA_EXAMPLE}") }
    assert_operator 3.0, :>, (duration_gara/duration_erb)
  end

  test "performance better than haml" do
    duration_haml = time(100) { Haml::Engine.new(HAML_EXAMPLE).render(self) }
    duration_gara = time(100) { Gara.render(self, "#{GARA_EXAMPLE}") }
    assert_operator 0.5, :>, (duration_gara/duration_haml)
  end

end

