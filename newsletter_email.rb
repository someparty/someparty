# frozen_string_literal: true

require 'nokogiri'

# Processes the Middeleman generated HTML of a newsletter article
# into text and html formats for sending through SES
class NewsletterEmail
  def initialize(article_slug)
    file_path = File.join(__dir__, 'dispatch', article_slug, 'index.html')

    unless File.exist?(file_path)
      puts "Error: Article /dispatch/#{article_slug}/index.html does not exist in the dispatch folder."
      exit
    end

    raw_html = File.read(file_path)

    if raw_html.empty?
      puts "Error: Article /dispatch/#{article_slug}/index.html exists but is empty."
      exit
    end

    @css = load_css
    @html_content = raw_html_to_html_body(raw_html)
    @text_content = raw_html_to_text_body(raw_html)
    @subject = retrieve_subject(@html_content)
  end

  attr_reader :html_content, :text_content, :subject, :css

  def raw_message(recipient)
    boundary = SecureRandom.hex

    <<~RAW_EMAIL
      From: "Adam White" <adam@someparty.ca>
      To: #{recipient['email']}
      Subject: Some Party: #{@subject}
      MIME-Version: 1.0
      Content-type: multipart/alternative; boundary="#{boundary}"
      List-Unsubscribe: <https://api.someparty.ca/some_party_unsubscribe?email=#{recipient['email']}&uuid=#{recipient['uuid']}>
      List-Unsubscribe-Post: List-Unsubscribe=One-Click

      --#{boundary}
      Content-type: text/plain; charset="UTF-8"
      Content-transfer-encoding: 7bit

      #{@text_content}
      \n\n
      You can unsubscribe from this newsletter by visiting: https://www.someparty.ca/unsubscribe?email=#{recipient['email']}&uuid=#{recipient['uuid']}

      --#{boundary}
      Content-type: text/html; charset="UTF-8"
      Content-transfer-encoding: 7bit

      <!doctype html>
      <html>
        <head>
          <style type="text/css">
            #{@css}
          </style>
          <title>Some Party: #{@subject}</title>
        </head>
        <body>
          #{@html_content}
          <div style='text-align: center; margin-top: 1em; margin-bottom: 2em;'><small>
            You can <a href="https://www.someparty.ca/unsubscribe?email=#{recipient['email']}&uuid=#{recipient['uuid']}">unsubscribe</a> from this newsletter at any time.
          </div></small>
        </body>
      </html>

      --#{boundary}--
    RAW_EMAIL
  end

  private

  def load_css
    css_path = File.join(__dir__, 'source', 'stylesheets', 'email.css')
    File.read(css_path)
  end

  def raw_html_to_html_body(html_content)
    # Parse the HTML
    doc = Nokogiri::HTML(html_content)

    # Select the <body> tag
    body = doc.at('body')

    body.inner_html.strip
  end

  def raw_html_to_text_body(html_content)
    # Parse the HTML
    doc = Nokogiri::HTML(html_content)

    # Select the <body> tag
    body = doc.at('body')

    # Remove <style> tags
    body.css('style').remove

    # Add line breaks before some block-level elements
    %w[p div br h1 h2 h3 h4 h5 h6 li].each do |tag|
      body.search(tag).each do |t|
        t.before("\n\n")
      end
    end

    # Rewrite links to bracket the URL after the linked text
    body.search('a').each do |link|
      link.replace("#{link.text} (#{link['href']})")
    end

    # Get the text content of the HTML document
    body.text.strip
  end

  def retrieve_subject(html_content)
    # Parse the HTML
    doc = Nokogiri::HTML(html_content)

    # Get the title of the article
    doc.css('h1').text
  end
end