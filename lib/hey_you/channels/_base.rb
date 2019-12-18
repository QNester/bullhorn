require 'hey_you/helper'
module HeyYou
  module Channels
    class Base
      include HeyYou::Helper
      extend HeyYou::Helper

      class << self
        def send!
          raise NotImplementedError, 'You should define #send! method in your channel.'
        end

        private

        def credentials_present?
          required_credentials.all? do |cred|
            if config.send(self.name.split('::').last.downcase).send(cred).nil?
              config.logger&.info(
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

        def ch_name
          self.class.name.split('::').last.downcase
        end

        def log(msg)
          config.log("[#{ch_name.upcase}] #{msg}")
        end
      end
    end
  end
end