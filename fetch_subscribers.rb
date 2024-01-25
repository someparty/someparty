require 'aws-sdk-dynamodb'
require 'json'

# Specify the output JSON file path
output_file_path = 'tmp/recipients.json'

# Load recipient data from the JSON file
recipients = JSON.parse(File.read(output_file_path))

unless recipients.empty?
  puts 'The recipients.json file is not empty. Do you want to overwrite it? (y/n)'
  answer = gets.chomp
  exit unless answer == 'y'
end

# Create a DynamoDB client
dynamodb = Aws::DynamoDB::Client.new(region: 'ca-central-1')

# Specify the table name
table_name = 'some_party_subscribers'

# Query DynamoDB to get all items in the table
response = dynamodb.scan(table_name:)

# Extract items from the response
items = response.items

# Write items to the JSON file
File.write(output_file_path, JSON.pretty_generate(items))

puts "#{items.count} subscribers written to #{output_file_path}"
