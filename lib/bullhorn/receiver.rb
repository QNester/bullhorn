require_relative 'sender'

module Bullhorn
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
    #   extend Bullhorn::Receiver
    #
    #   receive(
    #     sms:   -> { number },
    #     push:  -> { push_tokens.value },
    #     email: -> { priority_email }
    #   )
    #
    #   ...
    # end
    #
    # user = User.new(number: 123, push_tokens: PushToken.new(value: "456"), priority_email: 'example@mail.com')
    # user.sms_ch_receive_info # => 123
    # user.push_ch_receive_info # => 456
    #
    def receive(receiver_data)
      check_channels(receiver_data.keys)

      @receiver_data = receiver_data
      @receiver_channels = receiver_data.keys
      bullhorn_config.registrate_receiver(self)

      define_receive_info_methods
    end

    private

    def check_channels(channels)
      channels.all? do |ch|
        next if bullhorn_config.registered_channels.include?(ch.to_sym)
        raise NotRegisteredChannel, "Channel #{ch} not registered. Registered channels: #{bullhorn_config.registered_channels}"
      end
      @received_channels = channels
    end

    def define_receive_info_methods
      receiver_channels.each do |ch|
        self.send(:define_method, "#{ch}_ch_receive_info", receiver_data[ch])
      end
    end

    def bullhorn_config
      Config.config
    end

    class NotRegisteredChannel < StandardError; end
  end
end