require_relative '_base'
require 'mail'

module HeyYou
  module Channels
    class Email < Base
      class << self
        def send!(builder, to:)
          raise CredentialsNotExists unless credentials_present?

          context = self
          mail = Mail.new do
            from HeyYou::Config.instance.email.from
            to to
            subject builder.email.subject
            body context.get_body(builder.email.body)
          end

          mail.delivery_method config.email.delivery_method
          p("[EMAIL] Send mail #{mail}")
          mail.deliver
        end

        def get_body(body_text)
          # TODO: Load layout here.
          body_text
        end

        def required_credentials
          %i[delivery_method from]
        end

      end

      class CredentialsNotExists < StandardError; end
    end
  end
end
