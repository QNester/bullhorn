require_relative '../mixins/conigurable'
require 'mail'

module Bullhorn
  class Config
    class Email
      extend ::Bullhorn::Mixins::Configurable

      DEFAULT_DELIVERY_METHOD = :sendmail

      attr_accessor :layout, :from, :delivery_method

      def initialize
        @delivery_method = DEFAULT_DELIVERY_METHOD
      end
    end
  end
end