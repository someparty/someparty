# standalone.rb
require 'optparse'
require 'aws-sdk-ses'
require 'nokogiri'

def html_to_text(html_content)
  # Parse the HTML
  doc = Nokogiri::HTML(html_content)

  # Add line breaks before some block-level elements
  %w[p div br h1 h2 h3 h4 h5 h6 li].each do |tag|
    doc.search(tag).each do |t|
      t.before("\n")
    end
  end

  # Get the text content of the HTML document
  doc.text.strip
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: send.rb [options]"

  opts.on("-pPATH", "--path=PATH", "Path to the HTML file") do |v|
    options[:path] = v
  end
end.parse!

raise OptionParser::MissingArgument if options[:path].nil?

file_path = File.join(__dir__, 'dispatch', options[:path], 'index.html')

html_content = File.read(file_path)
text_content = html_to_text(html_content)

# Initialize the SES client
ses = Aws::SES::Client.new(region: 'ca-central-1') # replace with your region

# Define the template parameters
template_name = 'Newsletter' # replace with your template name
template_params = {
  template: {
    template_name: template_name,
    subject_part: 'Some Party: {{article_title}}',
    html_part: '{{html_body}} to unsubscribe use {{email}} and {{uuid}}',
    text_part: '{{text_body}} to unsubscribe use {{email}} and {{uuid}}'
  }
}

# Create or update the template
begin
  ses.get_template(template_name: template_name)
  ses.update_template(template: template_params[:template])
rescue Aws::SES::Errors::TemplateDoesNotExist
  ses.create_template(template: template_params[:template])
end

# The message may not include more than 50 recipients, across the To:, CC: and BCC: fields. If you need to send an email message to a larger audience, you can divide your recipient list into groups of 50 or fewer, and then call the SendBulkTemplatedEmail operation several times to send the message to each group.

# Define the email parameters
email_params = {
  source: 'adam@someparty.ca',
  destinations: [
    {
      destination: {
        to_addresses: ['adam+test@someparty.ca'],
      },
      replacement_template_data: %({
        "email": "adam+test@someparty.ca",
        "uuid": "12345678-1234-1234-1234-123456789012"
      })
    }
  ],
  template: 'Newsletter',
  default_template_data: %({
    "html_body": #{html_content.to_json},
    "text_body": #{text_content.to_json},
    "article_title": "Test Email 2"
  })
}

puts  %({
  "html_body": #{html_content.to_json},
  "text_body": #{text_content.to_json},
  "article_title": "Test Email 2"
})

puts 'Sending email...'

begin
  response = ses.send_bulk_templated_email(email_params)
  puts response
rescue Aws::SES::Errors::ServiceError => error
  puts "Email not sent: #{error.message}"
end

