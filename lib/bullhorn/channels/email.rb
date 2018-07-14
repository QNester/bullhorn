require_relative '_base'
require 'mail'

module Bullhorn
  module Channels
    class Email < Base
      class << self
        def send!(builder, to:)
          # config.email.set_email_config

          mail = Mail.deliver do
            from config.email.from
            to to
            subject builder.email.subject
            body get_body(builder.email.body)
          end
        end

        def get_body(body_text)
          # TODO: Load layout here.
          body_text
        end
      end
    end
  end
end
