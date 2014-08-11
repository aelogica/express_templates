require 'nokogiri'

module Gara

  HTML5_TAGS = [:a, :abbr, :address, :area, :article, :aside, :audio,
                    :b, :base, :bdi, :bdo, :blockquote, :body, :br, :button,
                    :canvas, :caption, :cite, :code, :col, :colgroup,
                    :data, :datalist, :dd, :del, :details, :dfn, :div, :dl, :dt,
                    :em, :embed,
                    :fieldset, :figcaption, :figure, :footer, :form,
                    :h1, :h2, :h3, :h4, :h5, :h6, :head, :header, :hr, :html,
                    :i, :iframe, :img, :input, :ins,
                    :kbd, :keygen,
                    :label, :legend, :li, :link,
                    :main, :map, :mark, :math, :menu, :menuitem, :meta, :meter,
                    :nav, :noscript,
                    :object, :ol, :optgroup, :option, :output,
                    :p, :param, :pre, :progress,
                    :q,
                    :rp, :rt, :ruby,
                    :s, :samp, :script, :section, :select, :small, :source,
                    :span, :strong, :style, :sub, :sup, :summary, :svg,
                    :table, :tbody, :td, :textarea, :tfoot, :th, :thead, :time, :title,
                    :tr, :track,
                    :u, :ul,
                    :var, :video,
                    :wbr]

  module DelegateMethods
    HTML5_TAGS.each do |tag|
      module_eval <<-RUBY
        def #{tag}(*args)
          @gara_delegate.#{tag}(*args) { yield if block_given? }
        end
RUBY
    end
  end

  module WrapperMethods
    HTML5_TAGS.each do |tag|
      module_eval <<-RUBY
        def #{tag}(*args)
          @doc.#{tag}(*args) { yield if block_given? }
        end
RUBY
    end
  end

  class ContextDelegate
    include WrapperMethods

    def initialize(view_context)
      @doc = Nokogiri::HTML::Builder.new
      delegate_html_5_methods_to_self(view_context)
    end

    def delegate_html_5_methods_to_self(view_context)
      view_context.instance_variable_set(:@gara_delegate, self)
      view_context.extend(DelegateMethods)
    end

    def to_html
      @doc.to_html
    end
  end
end