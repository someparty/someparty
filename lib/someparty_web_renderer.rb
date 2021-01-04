# frozen_string_literal: true

require 'middleman-core/renderers/redcarpet'

# Extends the Redcarpet Markdown parser to generate Tachyons style CSS markup
class SomePartyWebRenderer < Middleman::Renderers::MiddlemanRedcarpetHTML
  def block_html(raw_html)
    doc = Nokogiri::HTML(raw_html)

    # The lazyload class triggers the lazysizes.js loader to prevent all media
    # from loading on page load. The src in an inframe has to be replaced with
    # data-src as well.

    doc.search('iframe').each do |iframe|
      iframe['data-src'] = iframe['src']
      iframe.remove_attribute('src')
    end

    if raw_html.include? 'youtube'
      doc.css('iframe').add_class('aspect-ratio--object lazyload')
      format("<div class='wide-media'><div class='overflow-hidden aspect-ratio aspect-ratio--16x9'>%s</div></div>",
             doc.to_html)
    elsif raw_html.include? 'facebook'
      doc.css('iframe').add_class('aspect-ratio--object lazyload')
      format("<div class='wide-media'><div class='overflow-hidden aspect-ratio aspect-ratio--16x9'>%s</div></div>",
             doc.to_html)
    elsif raw_html.include? 'brightcove'
      doc.css('iframe').add_class('aspect-ratio--object lazyload')
      format("<div class='wide-media'><div class='overflow-hidden aspect-ratio aspect-ratio--16x9'>%s</div></div>",
             doc.to_html)
    elsif raw_html.include? 'vimeo'
      doc.css('iframe').add_class('aspect-ratio--object lazyload')
      format("<div class='wide-media'><div class='overflow-hidden aspect-ratio aspect-ratio--16x9'>%s</div></div>",
             doc.to_html)
    elsif raw_html.include? 'instagram'
      doc.css('blockquote').add_class('dib tl')
      doc.css('iframe').add_class('lazyload')
      format("<div class='center tc'><div class='dib tl w-100 maxread'>%s</div></div>", doc.to_html)
    elsif raw_html.include? 'twitter-tweet'
      doc.css('blockquote').add_class('dib tl')
      doc.css('iframe').add_class('lazyload')
      format("<div class='wide-media'><div class='center tc'><div class='dib tl w-100 maxread'>%s</div></div></div>", doc.to_html)
    elsif raw_html.include? 'bandcamp'
      doc.css('iframe').add_class('lazyload')
      # Bandcamp's narrow player doesn't center nicely with the provided inline styles
      if raw_html.include? 'border: 0; width: 100%; height: 120px;'
        doc.at_css('iframe').set_attribute('style', 'border: 0; width: 700px; max-width: 100%; height: 120px;')
      end
      format("<div class='center tc'>%s</div>", doc.to_html)
    elsif raw_html.include? 'cbc'
      if raw_html.include? 'data-no-video=1'
        doc.css('iframe').add_class('lazyload')
        format("<div class='center tc'><div class='dib tl w-100 maxread'>%s</div></div>", doc.to_html)
      else
        doc.css('iframe').add_class('aspect-ratio--object lazyload')
        format("<div class='wide-media'><div class='overflow-hidden aspect-ratio aspect-ratio--16x9'>%s</div></div>",
               doc.to_html)
      end
    elsif raw_html.include? 'npr.org'
      doc.css('iframe').add_class('aspect-ratio--object lazyload')
      format("<div class='wide-media'><div class='overflow-hidden aspect-ratio aspect-ratio--16x9'>%s</div></div>",
             doc.to_html)
    elsif raw_html.include? 'soundcloud'
      doc.css('iframe').add_class('lazyload')
      format("<div class='wide-media'><div class='center tc'>%s</div></div>", doc.to_html)
    else
      doc.css('iframe').add_class('lazyload')
      format("<div class='center tc'>%s</div>", doc.to_html)
    end
  end

  def block_quote(text)
    format('<blockquote class="maxquote center pl4 black-60 bl bw2 b--red">%s</blockquote>', text)
  end

  def header(text, header_level)
    format('<h%s class="maxread center">%s</h%s>', header_level,
           text, header_level)
  end

  def hrule
    "<hr class='bg-black-30 mt4 mb4 maxread bn hr-1'/>"
  end

  def link(link, title, content)
    # Below embedded media I want to insert a simple link
    # to the source, which we'll use primarily in the emails
    # but don't want to take up too much space on the web
    # This type of link we'll detect in the markdown if it has
    # a title that starts with "#", which is a little kludgy but
    # doesn't break the source Markdown

    css_class = 'black no-underline fw4 bb b--black'

    if title
      if title.start_with?('#')
        css_class = 'black no-underline fw4 db tc f6 nt3 mb4'
        if title.length > 1
          title[0] = ''
        else
          title = nil
        end
      end
    end

    if !@local_options[:no_links]
      attributes = { title: title, class: css_class, target: '_blank' }
      attributes.merge!(@local_options[:link_attributes]) if @local_options[:link_attributes]
      scope.link_to(content, link, attributes)
    else
      link_string = link.dup
      link_string << %("#{title}") if title && !title.empty? && title != alt_text
      "[#{content}](#{link_string})"
    end
  end

  def list(content, list_type)
    case list_type
    when :ordered
      format("<ol class='maxread center'>%s</ol>", content)
    when :unordered
      format("<ul class='maxread center'>%s</ul>", content)
    end
  end

  def paragraph(text)
    if text.include? '<img'
      format("<p class='tc center'>%s</p>", text)
    elsif text.include? '<small'
      format("<p class='maxread center mt0'>%s</p>", text)
    else
      format("<p class='maxread center'>%s</p>", text)
    end
  end
end
