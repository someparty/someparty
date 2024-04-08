require 'optparse'
require 'aws-sdk-dynamodb'
require 'json'

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: fetch_contest_entries.rb [options]'

  opts.on('-cCONTEST', '--contest=CONTEST', 'Contest name') do |v|
    options[:contest] = v
  end

  opts.on('-p', '--purge', 'Purge entries') do
    options[:purge] = true
  end
end.parse!

raise OptionParser::MissingArgument if options[:contest].nil?

# Specify the output JSON file path
output_file_path = "tmp/contest-entries-#{options[:contest]}.json"

# Create the file if it doesn't exist
unless File.exist?(output_file_path)
  File.new(output_file_path, 'w')
  File.write(output_file_path, '[]')
end

# Load entries data from the JSON file
entries = JSON.parse(File.read(output_file_path))

unless entries.empty?
  puts "The contest-entries-#{options[:contest]}.json file is not empty. Do you want to overwrite it? (y/n)"
  answer = gets.chomp
  exit unless answer == 'y'
end

# Create a DynamoDB client
dynamodb = Aws::DynamoDB::Client.new(region: 'ca-central-1')

# Specify the table name
table_name = 'some_party_contest_entries'

last_evaluated_key = nil
entries = 0

loop do
  # Query DynamoDB to get all items in the table
  response = dynamodb.scan(
    table_name:,
    exclusive_start_key: last_evaluated_key
  )

  # Extract items from the response
  items = response.items

  # Filter items that match the contest
  filtered_items = items.select { |item| item['contest'] == options[:contest] }

  # Write filtered items to the JSON file
  File.write(output_file_path, JSON.pretty_generate(filtered_items))

  entries += filtered_items.count

  if options[:purge]
    # Delete items that match the contest
    filtered_items.each do |item|
      dynamodb.delete_item(
        table_name:,
        key: {
          'email' => item['email'],
          'contest' => item['contest']
        }
      )
    end
  end

  break if response.last_evaluated_key.nil?

  last_evaluated_key = response.last_evaluated_key
end

puts "#{entries} entries written to #{output_file_path}"
puts "#{entries} deleted from the cloud" if options[:purge]
