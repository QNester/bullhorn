require_relative '_base'
require 'mail'

module HeyYou
  module Channels
    class Email < Base
      class << self
        def send!(builder, to:, **options)
          raise CredentialsNotExists unless credentials_present?

          method = config.email.default_mailing ? :send_via_mail : :send_via_custom_class
          public_send(method, builder, to, options)
        end

        # Send email via custom class instance.
        def send_via_custom_class(builder, to, **options)
          mailer = mailer_class_from_builder(builder, options)

          mailer_method = options[:mailer_method] ||
            builder.email.mailer_method ||
            config.email.default_mailer_method

          delivery_method = options[:delivery_method] ||
            builder.email.delivery_method ||
            config.email.default_delivery_method

          log("Build mail via #{mailer}##{mailer_method}. Delivery with #{delivery_method}")
          mailer_msg = mailer.public_send(mailer_method, data: builder.email, to: to)
          mailer_msg.public_send(delivery_method)
        end

        # Send email with standard mail (gem 'mail')
        def send_via_mail(builder, to, **_)
          context = self
          mail = Mail.new do
            from HeyYou::Config.instance.email.from
            to to
            subject builder.email.subject
            body context.get_body(builder.email.body)
          end

          mail.delivery_method config.email.mail_delivery_method
          log("Send mail #{mail}")
          mail.deliver
        end

        def get_body(body_text)
          # TODO: Load layout from config here.
          body_text
        end

        def required_credentials
          %i[from]
        end

        private

        def mailer_class_from_builder(builder, **options)
          mailer_class = options[:mailer_class] ||
            builder.email.mailer_class ||
            config.email.default_mailer_class
          unless mailer_class
            raise(
              MailerClassNotDefined,
              'You must set mailer_class in notifications collection or pass :mailer_class option'
            )
          end

          begin
            mailer = Object.const_get(mailer_class.to_s)
          rescue NameError
            raise ActionMailerClassNotDefined, "Mailer #{mailer_class} not initialized"
          end

          mailer
        end
      end

      class CredentialsNotExists < StandardError;
      end
      class ActionMailerClassNotDefined < StandardError;
      end
      class MailerClassNotDefined < StandardError;
      end
    end
  end
end
