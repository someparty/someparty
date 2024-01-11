require 'aws-sdk-ses'
require 'limiter'

class EmailSender
  extend Limiter::Mixin

  limit_method(:send_email, rate: 14, interval: 1, balanced: true) do
    puts "Rate limit reached at #{Time.now}, waiting..."
  end

  def initialize
    @ses = Aws::SES::Client.new(region: 'ca-central-1')
  end

  def send_email(recipient, newsletter)
    @ses.send_raw_email(
      {
        source: 'adam@someparty.ca',
        raw_message: { data: newsletter.raw_message(recipient) },
        destinations: [recipient['email']]
      }
    )
  end
end
