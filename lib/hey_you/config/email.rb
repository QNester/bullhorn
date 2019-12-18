require 'hey_you/config/conigurable'
require 'mail'

module HeyYou
  class Config
    class Email
      extend Configurable

      MAIL_DELIVERY_METHOD = :sendmail
      DEFAULT_ACTION_MAILER_METHOD = :send!
      DEFAULT_DELIVERY_METHOD = :deliver_now

      attr_accessor(
        :from,
        :mail_delivery_method,
        :default_mailing,
        :default_delivery_method,
        :default_mailer_class,
        :default_mailer_method
      )

      def initialize
        @mail_delivery_method ||= MAIL_DELIVERY_METHOD
        @default_mailing ||= !default_mailer_class.nil?
        @async ||= true
        @default_mailer_method ||= DEFAULT_ACTION_MAILER_METHOD
        @default_delivery_method ||= DEFAULT_DELIVERY_METHOD
      end
    end
  end
end