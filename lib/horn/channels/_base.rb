module Horn
  module Channels
    class Base
      class << self
        def send!
          raise NotImplementedError, 'You should define #send! method in your channel.'
        end

        private

        def credentials_present?
          required_credentials.all? do |cred|
            if config.send(self.name.split('::').last.downcase).send(cred).nil?
              # TODO: Log warn
              p(
                "[WARN] required credential was not set. " +
                "Set `config.#{self.name.downcase}.#{cred}` to send notification with #{self.name.downcase}"
              )
              return false
            end
            true
          end
        end

        def required_credentials
          []
        end

        def config
          Config.config
        end
      end
    end
  end
end