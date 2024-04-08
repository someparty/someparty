require 'aws-sdk-dynamodb'
require 'json'
require 'aws-sdk-cloudwatchlogs'

SOME_PARTY_SUBSCRIBERS = 'some_party_subscribers'.freeze
SOME_PARTY_CONTEST_ENTRIES = 'some_party_contest_entries'.freeze

def valid_email?(email)
  # Simple regex to validate email format
  email =~ /\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i
end

def lambda_handler(event:, context:)
  return if event['body'].nil?

  body = JSON.parse(event['body'])
  email = body['email']
  contest = body['contest']

  # Sanitize the email
  email = email&.strip&.downcase

  # Validate email format
  unless valid_email?(email)
    return {
      statusCode: 400,
      body: 'Invalid email format'
    }
  end

  handle_email(email, contest)
end

def handle_email(email, contest)
  dynamo_db = Aws::DynamoDB::Client.new(region: 'ca-central-1')
  subscriber = confirm_subscriber(dynamo_db, email)

  if subscriber
    logger("Contest entry #{contest} requested for #{email}")

    if entry_exists?(dynamo_db, email, contest)
      logger("Contest entry already exists for #{contest}: #{email}")
    else
      enter_contest(dynamo_db, email, contest)
      logger("New contest entry for #{contest}: #{email}")
    end
  else
    logger("Contest entry #{contest} requested for #{email}, but that's not a valid subscriber")
  end

  {
    statusCode: 200,
    body: 'Your entry has been received. Note that only entires from current subscribers are eligable to win. This response is not an indication of your subscription status.'
  }
end

def confirm_subscriber(dynamo_db, email)
  existing_subscriber = dynamo_db.query(
    {
      table_name: SOME_PARTY_SUBSCRIBERS,
      key_condition_expression: 'email = :email',
      expression_attribute_values: {
        ':email' => email
      }
    }
  )
  return false if existing_subscriber.items.empty?

  existing_subscriber.items.first
end

def entry_exists?(dynamo_db, email, contest)
  existing_entry = dynamo_db.query(
    {
      table_name: SOME_PARTY_CONTEST_ENTRIES,
      key_condition_expression: 'email = :email AND contest = :contest',
      expression_attribute_values: {
        ':email' => email,
        ':contest' => contest
      }
    }
  )
  !existing_entry.items.empty?
end

def enter_contest(dynamo_db, email, contest)
  current_datetime = Time.now.utc
  timestamp_entered = current_datetime.to_i

  dynamo_db.put_item({
                       table_name: SOME_PARTY_CONTEST_ENTRIES,
                       item: {
                         'email' => email,
                         'contest' => contest,
                         'date_entered' => current_datetime.strftime('%Y-%m-%dT%H:%M:%SZ'),
                         'timestamp_entered' => timestamp_entered
                       }
                     })
end

def logger(message)
  # Logging to CloudWatch Logs
  log_group_name = 'some_party'
  log_stream_name = 'some_party_enter_contest'
  cloudwatch_logs = Aws::CloudWatchLogs::Client.new(region: 'ca-central-1')

  cloudwatch_logs.put_log_events(
    {
      log_group_name:,
      log_stream_name:,
      log_events: [
        {
          timestamp: Time.now.to_i * 1000,
          message:
        }
      ]
    }
  )
end
