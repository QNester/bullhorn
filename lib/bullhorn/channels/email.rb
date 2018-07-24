require_relative '_base'
require 'mail'

module Bullhorn
  module Channels
    class Email < Base
      class << self
        def send!(builder, to:)
          return unless credentials_present?

          mail = Mail.new do
            from Config.config.email.from
            to to
            subject builder.email.subject
            body { get_body(builder.email.body) }
          end

          mail.delivery_method Config.config.email.delivery_method
          p("[EMAIL] Send mail #{mail}")
          mail.deliver
        end

        def get_body(body_text)
          # TODO: Load layout here.
          body_text
        end

        def required_credentials
          [:delivery_method, :from]
        end
      end
    end
  end
end
