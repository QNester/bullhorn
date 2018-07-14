require_relative 'builder'

require_relative 'channels/push'
require_relative 'channels/sms'
require_relative 'channels/email'

module Bullhorn
  class Sender
    class << self
      def send!(notification_key, to:, **options)
        builder = Builder.new(notification_key)
        config.registered_channels.each do |ch|
          if channel_allowed?(ch, to, builder, options)
            Channels.const_get(ch.to_s.capitalize).send!(builder, to: to[ch])
          end
        end
      end

      def channel_allowed?(ch, to, builder, **options)
        return false unless to[ch.to_sym] || to[ch.to_s]
        channel_allowed_by_only?(ch, options[:only]) && !builder.send(ch).nil?
      end

      private

      def channel_allowed_by_only?(ch, only)
        return true unless only
        return only.map(&:to_sym).include?(ch.to_sym) if only.is_a?(Array)
        only.to_sym == ch.to_sym
      end

      def config
        Config.config
      end
    end
  end
end