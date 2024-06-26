require 'aws-sdk-dynamodb'
require 'securerandom'
require 'json'
require 'aws-sdk-cloudwatchlogs'

SOME_PARTY_SUBSCRIBERS = 'some_party_subscribers'.freeze

def valid_email?(email)
  # Simple regex to validate email format
  email =~ /\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i
end

def lambda_handler(event:, context:)
  body = JSON.parse(event['body'])
  email = body['email']&.strip&.downcase

  # Validate email format
  unless valid_email?(email)
    return {
      statusCode: 400,
      body: 'Invalid email format'
    }
  end

  dynamo_db = Aws::DynamoDB::Client.new(region: 'ca-central-1')

  if email_exists?(dynamo_db, email)
    logger("Subscriptipion #{email} already exists")
  else
    create_subscriber(dynamo_db, email)
    logger("New subscription #{email}")
  end

  # Note if we opt to display this string to the caller we probably don't want the
  # response to say anything regarding the subscription status of the request so that
  # the function can't be used to fish for subscriber names.
  {
    statusCode: 200,
    body: "Subscribed #{email}"
  }
end

def email_exists?(dynamo_db, email)
  existing_subscriber = dynamo_db.query(
    {
      table_name: SOME_PARTY_SUBSCRIBERS,
      key_condition_expression: 'email = :email',
      expression_attribute_values: {
        ':email' => email
      }
    }
  )
  !existing_subscriber.items.empty?
end

def create_subscriber(dynamo_db, email)
  uuid = SecureRandom.uuid
  current_datetime = Time.now.utc
  timestamp_subscribed = current_datetime.to_i

  dynamo_db.put_item({
                       table_name: SOME_PARTY_SUBSCRIBERS,
                       item: {
                         'email' => email,
                         'uuid' => uuid,
                         'date_subscribed' => current_datetime.strftime('%Y-%m-%dT%H:%M:%SZ'),
                         'timestamp_subscribed' => timestamp_subscribed
                       }
                     })
end

def logger(message)
  # Logging to CloudWatch Logs
  log_group_name = 'some_party'
  log_stream_name = 'some_party_subscribe'
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
