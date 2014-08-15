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
      @builder = Nokogiri::HTML::Builder.with(@doc)
    end

    def add_methods_to(context)
      builder = @builder
      # Open the eigenclass of the passed in context
      eigenclass_of_context = class << context ; self ; end

      # add procs as methods for each html5 tag to the context
      _proc_hash(@builder).each do |method_name, proc|
        eigenclass_of_context.send(:define_method, method_name, &proc)
      end

      # provide a self << on context that delegates to the nokogiri builder
      # so that we can insert the results of rails helpers
      eigenclass_of_context.send(:define_method, :<<) do |string|
        builder << string if string.kind_of?(String)
      end

      # override/wrap helper methods that presumably return strings
      # so that they insert their markup into the nokogiri builder
      _helper_methods_from(eigenclass_of_context).each do |method|
        eigenclass_of_context.class_eval do
          define_method method do |*args, &block_for_helper|
            result = super(*args, &block_for_helper)
            if result.kind_of? String
              # uncomment to see if we are inapproriately wrapping some helper
              # puts "#{method} returned: #{result}"
              self << result
            else
              result
            end
          end
        end
      end

    end

    def emit
      nodes = @doc.children
      if nodes.length.eql?(1) && nodes.first.name.eql?("html")
        # necessary to include doctype - TODO: avoid calling to_html twice
        Nokogiri::HTML::Document.parse( @doc.to_html ).to_xhtml(indent: 2)
      else
        @doc.to_html
      end
    end

    private
      # we only want to wrap helpers that return strings which should be
      # inserted as markup into the document so we identify which methods
      # should NOT be wrapped here and exclude them
      def _helper_methods_from(eigenclass_of_context)
        helpers = ((eigenclass_of_context.instance_methods - HTML5_TAGS) - Object.instance_methods) - 
          [:tag, :_layout_for, :path_to_, :form_authenticity_token, :content_tag]
        helpers.reject do |method|
          method.to_s.match(/(_\d+_\d+$)|(lookup_context)|(<<)|(_url$)|(_path$)|(compute_.*$)|(asset)|(path_to_.*)/)
        end
      end

      def _proc_hash(nokogiri)
        proc_hash = HTML5_TAGS.inject({}) do |hash, tag|
          # nokogiri's builder is now a local binding so we can access it
          # from inside an instance of Context (procs preserve local bindings)
          builder = nokogiri
          hash[tag] = -> (*args, &block) {
             result = nil
             begin
               builder.public_send(tag, *args) do # public send is necessary due to send accessing private method Kernel#p
                 unless block.nil?
                   result = block.call            # necessary to make sure block executes in Context not Builder
                   if result.kind_of?(String)
                     self << result               # add any string returned to the document so that: p { "works" } yields "<p>works</p>"
                   else
                     result
                   end
                 end
               end
             rescue Exception => e
               binding.pry
             end
           }
           hash
        end
      end

  end
end