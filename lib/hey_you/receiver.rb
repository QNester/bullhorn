require_relative 'sender'

module HeyYou
  module Receiver
    attr_reader :receiver_channels, :receiver_data

    def self.extended klass
      klass.class_eval do
        # Method will be injected for instances methods of class.
        #
        # This can use something like: user.send_notification('key', options).
        def send_notification(notification_key, **options)
          Sender.send_to(self, notification_key, options)
        end
      end
    end

    # Registrate class as receiver.
    # In parameters pass hash where keys - channels names, and values -
    # procs with values for receive.
    #
    # For instances of classes will be created methods `#{channel_name}_ch_receive_info`
    # after registrate your class as receiver.
    #
    # Example:
    #
    # class User
    #   extend HeyYou::Receiver
    #
    #   receive(
    #     push:  -> { push_tokens.value },
    #     email: -> { priority_email }
    #   )
    #
    #   ## Or you can use receive with options:
    #   receive(
    #     email: { subject: -> { priority_email }, options: { mailer_class: UserMailer, mailer_method: :notify } }
    #   )
    #
    #   ...
    # end
    #
    # user = User.new( push_tokens: PushToken.new(value: "456"), priority_email: 'example@mail.com')
    # user.push_ch_receive_info # => 456
    #
    def receive(receiver_data)
      check_channels(receiver_data.keys)

      @receiver_data = receiver_data
      @receiver_channels = receiver_data.keys
      hey_you_config.registrate_receiver(self)

      define_receive_info_methods
    end

    private

    def check_channels(channels)
      channels.all? do |ch|
        next if hey_you_config.registered_channels.include?(ch.to_sym)
        raise(
          NotRegisteredChannel,
          "Channel #{ch} not registered. Registered channels: #{hey_you_config.registered_channels}"
        )
      end
      @received_channels = channels
    end

    # We can
    def define_receive_info_methods
      receiver_channels.each do |ch|
        if receiver_data[ch].is_a?(Hash)
          me = self
          self.send(:define_method, "#{ch}_ch_receive_info", receiver_data[ch].fetch(:subject))
          self.send(:define_method, "#{ch}_ch_receive_options", -> { me.receiver_data[ch].fetch(:options, {}) })
        else
          self.send(:define_method, "#{ch}_ch_receive_info", receiver_data[ch])
          self.send(:define_method, "#{ch}_ch_receive_options", -> { {} })
        end
      end
    end

    def hey_you_config
      Config.config
    end

    class NotRegisteredChannel < StandardError;
    end
  end
end