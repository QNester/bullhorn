require_relative 'builder'

require_relative 'channels/push'
require_relative 'channels/sms'
require_relative 'channels/email'

module Horn
  class Sender
    class << self
      def send_to(receiver, notification_key, **options)
        unless receiver_valid?(receiver)
          raise NotRegisteredReceiver, "Class '#{receiver.class}' not registered as receiver"
        end

        to_hash = {}
        receiver.class.receiver_channels.each do |ch|
          to_hash[ch] = receiver.send("#{ch}_ch_receive_info")
        end
        send!(notification_key, to: to_hash, **options)
      end

      def send!(notification_key, to:, **options)
        builder = Builder.new(notification_key, options)
        response = {}
        config.registered_channels.each do |ch|
          if channel_allowed?(ch, to, builder, options)
            response[ch] = Channels.const_get(ch.to_s.capitalize).send!(builder, to: to[ch])
          end
        end
        response
      end

      private

      def channel_allowed?(ch, to, builder, **options)
        return false unless to[ch.to_sym] || to[ch.to_s]
        channel_allowed_by_only?(ch, options[:only]) && !builder.send(ch).nil?
      end

      def receiver_valid?(receiver)
        config.registered_receivers.include?(receiver.class)
      end

      def channel_allowed_by_only?(ch, only)
        return true unless only
        return only.map(&:to_sym).include?(ch.to_sym) if only.is_a?(Array)
        only.to_sym == ch.to_sym
      end

      def config
        Config.config
      end
    end

    class NotRegisteredReceiver < StandardError; end
  end
end