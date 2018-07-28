require_relative 'conigurable'
require 'mail'

module Horn
  class Config
    class Email
      extend Configurable

      DEFAULT_DELIVERY_METHOD = :sendmail

      attr_accessor :layout, :from, :delivery_method

      def initialize
        @delivery_method = DEFAULT_DELIVERY_METHOD
      end
    end
  end
end