require 'nokogiri'

module Gara

  HTML5_TAGS = [ :a, :abbr, :address, :area, :article, :aside, :audio,
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
                 :wbr, :<<]

  class Html5Emitter

    module TagMethodsWithAfterProcessor
      Gara::HTML5_TAGS.each do |tag|
        Gara::Delegator.define_delegate tag, on: self, after_processor: -> (ctx, result) { ctx << result }
      end
    end


    attr_accessor :target
    def initialize
      @doc = Nokogiri::HTML::DocumentFragment.parse("")
      @gara_delegate = Nokogiri::HTML::Builder.with(@doc)
    end

    def add_methods_to(context)
      proc_hash = HTML5_TAGS.inject({}) { |hash, tag|
          hash[tag] = -> (*args) { self.send(tag, *args) ; yield if block_given? }
          hash
        }
      proc_hash.each do |method_name, proc|
        class << context
          binding.pry
          define_method(method_name, &proc)
        end
      end
    end

    def emit
      nodes = @doc.children
      if nodes.length.eql?(1) && nodes.first.name.eql?("html")
        # necessary to include doctype - TODO: avoid calling to_html twice
        Nokogiri::HTML::Document.parse( @doc.to_html ).to_html
      else
        @doc.to_html
      end
    end

  end
end