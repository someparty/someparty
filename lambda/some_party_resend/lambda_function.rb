require 'aws-sdk-dynamodb'
require 'aws-sdk-cloudwatchlogs'
require 'aws-sdk-ses'
require 'cgi'
require 'json'

SOME_PARTY_SUBSCRIBERS = 'some_party_subscribers'.freeze

def valid_email?(email)
  # Simple regex to validate email format
  email =~ /\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i
end

def lambda_handler(event:, context:)
  return if event['body'].nil?

  body = JSON.parse(event['body'])
  email = body['email']

  # Sanitize the email
  email = email&.strip&.downcase

  # Validate email format
  unless valid_email?(email)
    return {
      statusCode: 400,
      body: 'Invalid email format'
    }
  end

  handle_email(email)
end

def handle_email(email)
  dynamo_db = Aws::DynamoDB::Client.new(region: 'ca-central-1')
  subscriber = confirm_subscriber(dynamo_db, email)

  if subscriber
    logger("Unsubscribe link requested for #{email}")
    send_unsubscribe_email(email, subscriber)
  else
    logger("Unsubscribe link requested for #{email}, but that's not a valid subscriber")
  end

  {
    statusCode: 200,
    body: 'Requested'
  }
end

def send_unsubscribe_email(email, subscriber)
  ses = Aws::SES::Client.new(region: 'ca-central-1')

  url_email = CGI.escape(email)
  url_uuid = CGI.escape(subscriber['uuid'])

  ses.send_email(
    {
      source: 'adam@someparty.ca',
      destination: {
        to_addresses: [email]
      },
      message: {
        body: {
          text: {
            data: "You can unsubscribe from this newsletter by visiting: https://www.someparty.ca/unsubscribe?email=#{url_email}&uuid=#{url_uuid}"
          },
          html: {
            data: "You can unsubscribe from this newsletter by visiting: https://www.someparty.ca/unsubscribe?email=#{url_email}&uuid=#{url_uuid}"
          }
        },
        subject: {
          data: 'Some Party unsubscribe link request'
        }
      }
    }
  )
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

def logger(message)
  # Logging to CloudWatch Logs
  log_group_name = 'some_party'
  log_stream_name = 'some_party_resend'
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
