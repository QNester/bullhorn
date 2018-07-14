require_relative '_base'

module Bullhorn
  module Channels
    class Sms < Base
      class << self
        def send!(builder, to:)
          config.sms.twilio_client.api.account.messages.create(
            from: config.sms.twilio_from_number,
            to: to,
            body: builder.sms.text
          )
        end
      end
    end
  end
end