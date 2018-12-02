require_relative 'builder'

require_relative 'channels/push'
require_relative 'channels/email'

module HeyYou
  class Sender
    class << self
      # Send notifications for receiver
      #
      # @input receiver [Instance of receiver class] - registrated receiver
      # @input notification_key [String] - key for notification builder
      # @input options [Hash]
      #   @option only [String/Array[String]] - whitelist for using channels
      #
      def send_to(receiver, notification_key, **options)
        unless receiver_valid?(receiver)
          raise NotRegisteredReceiver, "Class '#{receiver.class}' not registered as receiver"
        end

        result = send!(notification_key, receiver, **options)
        config.log("Sender result: #{result}")
        result
      end

      def send!(notification_key, receiver, **options)
        to_hash = {}
        receiver.class.receiver_channels.each do |ch|
          to_hash[ch] = {
            # Fetch receiver's info for sending: phone_number, email, etc
            subject: receiver.public_send("#{ch}_ch_receive_info"),
            # Fetch receiver's options like :mailer_class
            options: receiver.public_send("#{ch}_ch_receive_options") || {}
          }
        end

        builder = Builder.new(notification_key, options)
        response = {}
        config.registered_channels.each do |ch|
          if channel_allowed?(ch, to_hash, builder, options)
            config.log(
              "Send #{ch} to #{to_hash[ch][:subject]} with data: #{builder.send(ch).data}" \
              " and options: #{to_hash[ch][:options]}"
            )
            response[ch] = Channels.const_get(ch.to_s.capitalize).send!(
              builder, to: to_hash[ch][:subject], **to_hash[ch][:options]
            )
          else
            config.log("Channel #{ch} not allowed.")
          end
        end
        response
      end

      private

      def channel_allowed?(ch, to, builder, **options)
        unless to[ch].is_a?(Hash) ? to[ch.to_sym][:subject] || to[ch.to_s][:subject] : to[ch.to_sym] || to[ch.to_s]
          return false
        end
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