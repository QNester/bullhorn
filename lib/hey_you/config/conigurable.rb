require 'singleton'

module HeyYou
  class Config
    module Configurable

      def self.extended klass
        klass.class_eval do
          include Singleton
        end
      end

      def configure(&block)
        @configured ? raise(AlreadyConfiguredError, 'You already configure HeyYou') : instance_eval(&block)
        @configured = true
        instance.validate_config if instance.respond_to?(:validate_config)
      end

      def config
        @config ||= self.instance
      end

      class AlreadyConfiguredError < StandardError; end
      class RequiredConfigsNotPassed < StandardError; end
    end
  end
end
