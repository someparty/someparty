require 'aws-sdk-dynamodb'
require 'json'
require 'aws-sdk-cloudwatchlogs'

SOME_PARTY_SUBSCRIBERS = 'some_party_subscribers'.freeze

def valid_email?(email)
  # Simple regex to validate email format
  email =~ /\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i
end

def lambda_handler(event:, context:)
  # The email and uuid may be in the query string if using a One-Click Unsubscribe link
  body = event['body'] ? JSON.parse(event['body']) : {}
  email = body['email'] || event['queryStringParameters']['email']
  uuid = body['uuid'] || event['queryStringParameters']['uuid']

  # Sanitize the email
  email = email&.strip&.downcase

  # Validate email format
  unless valid_email?(email)
    return {
      statusCode: 400,
      body: 'Invalid email format'
    }
  end

  dynamo_db = Aws::DynamoDB::Client.new(region: 'ca-central-1')

  if subscriber_exists(dynamo_db, email, uuid)
    unsubscribe_subscriber(dynamo_db, email, uuid)
    # Log the unsubscribe event
    logger("Unsubscribed #{email} (UUID: #{uuid})")

    {
      statusCode: 200,
      body: "Unsubscribed #{email}"
    }
  else
    # Email and UUID combination not found, return an error response
    {
      statusCode: 404,
      body: "Subscriber not found for email #{email} and UUID #{uuid}"
    }
  end
end

def unsubscribe_subscriber(dynamo_db, email, uuid)
  dynamo_db.delete_item(
    {
      table_name: SOME_PARTY_SUBSCRIBERS,
      key: {
        'email' => email,
        'uuid' => uuid
      }
    }
  )
end

def subscriber_exists(dynamo_db, email, uuid)
  # Check if the email and UUID combination exists
  existing_subscriber = dynamo_db.query(
    {
      table_name: SOME_PARTY_SUBSCRIBERS,
      key_condition_expression: '#email = :email AND #uuid = :uuid',
      expression_attribute_names: {
        '#email' => 'email',
        '#uuid' => 'uuid'
      },
      expression_attribute_values: {
        ':email' => email,
        ':uuid' => uuid
      }
    }
  )

  existing_subscriber.items.any?
end

def logger(message)
  # Logging to CloudWatch Logs
  log_group_name = 'some_party'
  log_stream_name = 'some_party_unsubscribe'
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
