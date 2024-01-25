require 'optparse'
require 'aws-sdk-dynamodb'
require 'csv'
require 'securerandom'
require 'debug'

def email_exists?(dynamo_db, table_name, email)
  existing_subscriber = dynamo_db.query(
    {
      table_name:,
      key_condition_expression: 'email = :email',
      expression_attribute_values: {
        ':email' => email
      }
    }
  )

  puts "#{email} already exists" unless existing_subscriber.items.empty?

  !existing_subscriber.items.empty?
end

def create_subscriber(dynamo_db, table_name, email, subscribed_at)
  uuid = SecureRandom.uuid
  timestamp_subscribed = subscribed_at.strftime('%s').to_i

  dynamo_db.put_item({
                       table_name:,
                       item: {
                         'email' => email,
                         'uuid' => uuid,
                         'date_subscribed' => subscribed_at.strftime('%Y-%m-%dT%H:%M:%SZ'),
                         'timestamp_subscribed' => timestamp_subscribed
                       }
                     })

  puts "Created subscriber #{email} at #{subscribed_at}"
end

def import_subscribers(csv, dynamo_db, table_name)
  CSV.foreach("tmp/#{csv}", headers: true) do |row|
    email = row['E-mail'].strip
    subscribed_at = DateTime.parse(row['Subscribe Date (GMT)'])

    create_subscriber(dynamo_db, table_name, email, subscribed_at) unless email_exists?(dynamo_db, table_name, email)
  end
end

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: import_subscribers.rb [options]'

  opts.on('-pPATH', '--path=PATH', 'Path to the CSV file') do |v|
    options[:path] = v
  end
end.parse!

raise OptionParser::MissingArgument if options[:path].nil?

dynamo_db = Aws::DynamoDB::Client.new(region: 'ca-central-1')
table_name = 'some_party_subscribers'

import_subscribers(options[:path], dynamo_db, table_name)
