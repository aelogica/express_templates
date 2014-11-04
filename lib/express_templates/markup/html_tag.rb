module ExpressTemplates
  module Markup
    class HtmlTag < Tag
      NON_VOID_TAGS = [:a, :abbr, :address, :article, :aside, :audio,
                       :b, :bdi, :bdo, :blockquote, :body, :button,
                       :canvas, :caption, :cite, :code, :colgroup,
                       :data, :datalist, :dd, :del, :details, :dfn, :div, :dl, :dt,
                       :em,
                       :fieldset, :figcaption, :figure, :footer, :form,
                       :h1, :h2, :h3, :h4, :h5, :h6, :head, :header, :html,
                       :i, :iframe, :ins,
                       :kbd,
                       :label, :legend, :li,
                       :main, :map, :mark, :math, :menu, :menuitem, :meter,
                       :nav, :noscript,
                       :object, :ol, :optgroup, :option, :output,
                       :p, :pre, :progress,
                       :q,
                       :rp, :rt, :ruby,
                       :s, :samp, :script, :section, :select, :small,
                       :span, :strong, :style, :sub, :sup, :summary, :svg,
                       :table, :tbody, :td, :textarea, :tfoot, :th, :thead, :time, :title, :tr,
                       :u, :ul,
                       :var, :video]

      VOID_TAGS =     [:area, :base, :br, :col, :command, :doctype, :embed, :hr, :img, :input,
                       :keygen, :link, :meta, :param, :source, :track, :wbr]

      ALL_TAGS = NON_VOID_TAGS + VOID_TAGS
    end

    HtmlTag::ALL_TAGS.each do |tag|
      klass = tag.to_s.titleize
      ExpressTemplates::Markup.module_eval "class #{klass} < ExpressTemplates::Markup::HtmlTag ; end"
    end

    HtmlTag::VOID_TAGS.each do |tag|
      klass = "ExpressTemplates::Markup::#{tag.to_s.titleize}"
      klass.constantize.class_eval do
        def close_tag
          ''
        end

        def transform_close_tag?
          false
        end
      end
    end

    Doctype.class_eval do
      def start_tag
        "<!DOCTYPE html>"
      end
    end

    I.class_eval do
      def should_not_abbreviate?
        true
      end
    end
  end
end
