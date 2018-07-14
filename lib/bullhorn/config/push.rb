require_relative '../mixins/conigurable'
require 'fcm'

module Bullhorn
  class Config
    class Push
      extend ::Bullhorn::Mixins::Configurable

      DEFAULT_PRIORITY = 'high'
      DEFAULT_TTL = 60
      DEFAULT_FCM_TIMEOUT = 30

      attr_accessor :fcm_token, :priority, :ttl, :fcm_timeout

      def initialize
        @priority = DEFAULT_PRIORITY
        @ttl = DEFAULT_TTL
        @fcm_timeout = DEFAULT_FCM_TIMEOUT
      end

      def fcm
        raise FcmTokenNotExists, 'Can\'t create fcm client: fcm_token not exists' unless fcm_token
        @fcm_client ||= FCM.new(fcm_token, timeout: fcm_timeout)
      end

      class FcmTokenNotExists < StandardError; end
    end
  end
end