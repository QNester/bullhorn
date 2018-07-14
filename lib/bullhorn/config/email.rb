require_relative '../mixins/conigurable'
require 'mail'

module Bullhorn
  class Config
    class Email
      extend ::Bullhorn::Mixins::Configurable

      DEFAULT_DELIVERY_METHOD = :test

      attr_accessor :layout, :from, :delivery_method

      def initialize
        @delivery_method = DEFAULT_DELIVERY_METHOD
        set_mail_config
      end

      def set_mail_config
        # Mail.defaults do
        #   delivery_method delivery_method
        # end
      end
    end
  end
end