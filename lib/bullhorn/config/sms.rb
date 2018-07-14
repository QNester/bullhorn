require_relative '../mixins/conigurable'
require 'twilio-ruby'

module Bullhorn
  class Config
    class Sms
      extend ::Bullhorn::Mixins::Configurable

      attr_accessor :twilio_account_sid, :twilio_auth_token
      attr_reader   :twilio_client

      def twilio_client
        @twilio_client ||= Twilio::REST::Client.new(twilio_account_sid, twilio_auth_token)
      end
    end
  end
end