require 'hey_you/helper'
require 'hey_you/builder'
require 'hey_you/channels/push'
require 'hey_you/channels/email'

module HeyYou
  class Sender
    include HeyYou::Helper
    extend HeyYou::Helper

    class << self
      # Send notifications for receiver
      #
      # @input receiver [Instance of receiver class] - registrated receiver
      # @input notification_key [String] - key for notification builder
      # @input options [Hash]
      #   @option only [String/Array[String]] - whitelist for using channels
      #   @option force [Boolean] - ignore `if` for receiver
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
          if !options[:force] && !receiver.public_send("#{ch}_ch_receive_condition")
            next
          end

          to_hash[ch] = {
            # Fetch receiver's info for sending: phone_number, email, etc
            subject: receiver.public_send("#{ch}_ch_receive_info"),
            # Fetch receiver's options like :mailer_class
            options: receiver.public_send("#{ch}_ch_receive_options") || {}
          }
        end

        send_to_receive_info(notification_key, to_hash, **options)
      end

      def send_to_receive_info(notification_key, receive_info, **options)
        builder = Builder.new(notification_key, **options)
        response = {}
        config.registered_channels.each do |ch|
          if channel_allowed?(ch, receive_info, builder, **options) && builder.respond_to?(ch) && builder.public_send(ch)
            config.log(
              "Send #{ch}-message to `#{receive_info[ch][:subject]}` with data: #{builder.public_send(ch).data}" \
              " and options: #{receive_info[ch][:options]}"
            )
            receive_options = receive_info[ch].fetch(:options, {}) || {}
            response[ch] = Channels.const_get(ch.to_s.capitalize).send!(
              builder, to: receive_info[ch][:subject], **receive_options
            )
          else
            config.log("Channel #{ch} not allowed or sending condition doesn't return truthy result.")
          end
        end
        response
      end

      private

      def channel_allowed?(ch, to, builder, **options)
        condition = to[ch].is_a?(Hash) ? to[ch.to_sym][:subject] || to[ch.to_s][:subject] : to[ch.to_sym] || to[ch.to_s]
        return false unless condition
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
    end

    class NotRegisteredReceiver < StandardError; end
  end
end