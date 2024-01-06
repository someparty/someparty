require 'optparse'
require 'aws-sdk-ses'
require 'json'
require 'date'
require_relative 'newsletter_email'

def update_log_file(subject, recipient, response, status)
  log_file_path = "log/send_log_#{Time.now.strftime('%Y-%m-%d')}.jsonl"

  log_entry = {
    subject: subject,
    email: recipient['email'],
    uuid: recipient['uuid'],
    datestamp: DateTime.now.iso8601,
    response:,
    status:
  }

  File.open(log_file_path, 'a') do |f|
    f.puts(log_entry.to_json)
  end
end

def update_remaining_recipient_list(recipients_file, successful_sends, recipients)
  puts "Successfully sent to #{successful_sends.count} of #{recipients.count} recipients."

  successful_sends.each do |recipient|
    recipients.reject! { |r| r['email'] == recipient }
  end

  # Write the remaining recipients back to the file, ideally none should be left.
  File.write("tmp/#{recipients_file}", JSON.pretty_generate(recipients)) unless recipients_file == 'test.json'
end

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: send.rb [options]'

  opts.on('-pPATH', '--path=PATH', 'Path to the HTML file') do |v|
    options[:path] = v
  end

  opts.on('-rRECIPIENTS', '--recipients=RECIPIENTS', 'Recipients file') do |v|
    options[:recipients] = v
  end

  options[:recipients] ||= 'test.json'
end.parse!

raise OptionParser::MissingArgument if options[:path].nil?

newsletter = NewsletterEmail.new(options[:path])
recipients = JSON.parse(File.read("tmp/#{options[:recipients]}"))

if recipients.empty?
  puts "Error: No recipients found in tmp/#{options[:recipients]} Do you need to re-dump the subscriber list?"
  exit
end

successful_sends = []

ses = Aws::SES::Client.new(region: 'ca-central-1')

recipients.each_with_index do |recipient, index|
  puts "Sending to #{index + 1} of #{recipients.count}: #{recipient['email']}"

  response = ses.send_raw_email(
    {
      source: 'adam@someparty.ca',
      raw_message: { data: newsletter.raw_message(recipient) },
      destinations: [recipient['email']]
    }
  )

  update_log_file(newsletter.subject, recipient, response.message_id, 'Success')
  successful_sends << recipient['email']
rescue Aws::SES::Errors::ServiceError => e
  update_log_file(newsletter.subject, recipient, e.message, 'Error')
  puts "Error sending to #{recipient['email']}: #{e.message}"
end

update_remaining_recipient_list(options[:recipients], successful_sends, recipients)
