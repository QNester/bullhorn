require_relative 'conigurable'
require 'twilio-ruby'

module Bullhorn
  class Config
    class Sms
      extend Configurable

      attr_accessor :twilio_account_sid, :twilio_auth_token, :twilio_from_number
      attr_reader   :twilio_client

      def twilio_client
        if twilio_account_sid && twilio_auth_token && twilio_from_number
          return @twilio_client ||= Twilio::REST::Client.new(twilio_account_sid, twilio_auth_token)
        end
        raise TwilioCredentialsNotExists, 'Can\'t create twilio client: twilio_account_sid, twilio_auth_token or twilio_from_number not exists'
      end

      class TwilioCredentialsNotExists < StandardError; end
    end
  end
end