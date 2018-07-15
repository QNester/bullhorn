require_relative '_base'

module Bullhorn
  module Channels
    class Sms < Base
      class << self
        def send!(builder, to:)
          return unless credentials_present?
          p("[SMS] Send sms from: #{config.sms.twilio_from_number} to: #{to}, text: #{builder.sms.text} with twilio.")
          config.sms.twilio_client.api.account.messages.create(
            from: config.sms.twilio_from_number,
            to: to,
            body: builder.sms.text
          )
        end

        def required_credentials
          [:twilio_from_number]
        end
      end
    end
  end
end