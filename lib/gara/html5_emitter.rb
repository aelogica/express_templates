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
                 :wbr]

  class Html5Emitter

    def self.debug(msg)
      puts msg if ENV['DEBUG']
    end

    def initialize
      @doc = Nokogiri::HTML::DocumentFragment.parse("")
      @gara_delegate = Nokogiri::HTML::Builder.with(@doc)
    end

    def add_methods_to(context)
      eigenclass_of_context = 
        class << context ; self ; end

      builder = @gara_delegate                   # create a local binding so we can access builder in an instance of Context
      proc_hash = HTML5_TAGS.inject({}) do |hash, tag|
          hash[tag] = -> (*args, &block) { 
            begin
              builder.public_send(tag, *args) do # public send is necessary due to send accessing private method Kernel#p
                unless block.nil?
                  result = block.call            # necessary to make sure block executes in Context not Builder
                  self << result if result.kind_of? String
                end
              end
            rescue Exception => e
              binding.pry
            end
          }
          hash
        end
      proc_hash.each do |method_name, proc|
        eigenclass_of_context.send(:define_method, method_name, &proc)
      end
      eigenclass_of_context.send(:define_method, :<<) do |string|
        builder << string
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