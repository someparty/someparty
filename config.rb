# frozen_string_literal: true

require 'fastimage'
require 'terser'

# Starting with an environment variable of 'email' will trigger emails style
# markdown rendering
medium = :web
medium = ENV['MEDIUM'].to_sym if ENV['MEDIUM']

set :medium, medium

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

###
# Helpers
###
require 'lib/someparty_helpers'
helpers SomePartyHelpers

require 'lib/someparty_email_renderer'
require 'lib/someparty_web_renderer'

activate :blog do |blog|
  blog.permalink = '{year}-{month}-{day}-{title}.html'
  # Matcher for blog source files
  blog.sources = 'articles/{year}-{month}-{day}-{title}.html'
  # blog.taglink = "tags/{tag}.html"

  blog.layout = if medium == :email
                  'layouts/email'
                else
                  'layouts/article'
                end

  # blog.summary_separator = /(READMORE)/
  # blog.summary_length = 250
  blog.year_link = '{year}.html'
  # blog.month_link = "{year}/{month}.html"
  # blog.day_link = "{year}/{month}/{day}.html"
  # blog.default_extension = ".markdown"

  # blog.tag_template = 'tag.html'
  blog.calendar_template = 'calendar.html'

  # Enable pagination
  # blog.paginate = true
  # blog.per_page = 1
  # blog.page_link = "page/{num}"

  blog.generate_day_pages = false
  blog.generate_month_pages = false
  blog.generate_tag_pages = false
  blog.generate_year_pages = true
end

page '/feed.xml', layout: false

# Reload the browser automatically whenever files change
configure :development do
  activate :livereload, apply_css_live: false, apply_js_live: false
end

activate :directory_indexes
page '/404.html', directory_index: false

activate :autoprefixer

set :markdown_engine, :redcarpet

if medium == :email
  set :markdown,
      fenced_code_blocks: true, highlight: true, renderer: SomePartyEmailRenderer
elsif medium == :web
  set :markdown,
      fenced_code_blocks: true, highlight: true, renderer: SomePartyWebRenderer
end

set :url_root, 'https://www.someparty.ca'

activate :search_engine_sitemap
activate :meta_tags

set :build_dir, 'dispatch' if medium == :email

# Build-specific configuration
configure :build do
  activate :robots,
           rules: [{ user_agent: '*', allow: %w[/] }],
           sitemap: 'https://www.someparty.ca/sitemap.xml'

  # Minify CSS on build
  activate :minify_css

  # Minify HTML on view
  activate :minify_html

  # Minify Javascript on build
  activate :minify_javascript, compressor: Terser.new

  activate :gzip unless medium == :email

  after_build do |_builder|
    FileUtils.cp_r 'public/.', 'build'
  end
end
