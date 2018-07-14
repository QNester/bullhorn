require 'singleton'

module Bullhorn
  module Mixins
    module Configurable

      def self.extended klass
        klass.class_eval do
          include Singleton
        end
      end

      def configure(&block)
        # TODO: log warn instead nil
        @configured ? nil : instance_eval(&block)
        @configured = true
      end

      def config
        @config ||= self.instance
      end
    end
  end
end