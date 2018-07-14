require 'singleton'
require 'yaml'

module Bullhorn
  class Config
    include Singleton

    DEFAULT_REGISTERED_CHANNELS = %i[sms email push]
    DEFAULT_SPLITTER = '.'

    attr_reader :collection, :env_collection, :configured
    attr_writer :collection_file
    attr_accessor :env_collection_file, :splitter, :registered_channels, :email_layout

    class CollectionFileNotDefined < StandardError; end

    class << self
      def configure(&block)
        # TODO: log warn instead nil
        @configured ? nil : instance_eval(&block)
        @configured = true
      end

      def config
        @config ||= Bullhorn::Config.instance
      end
    end

    def initialize
      @registered_channels = DEFAULT_REGISTERED_CHANNELS
      @splitter = DEFAULT_SPLITTER
    end

    def collection_file
      @collection_file || raise(
        CollectionFileNotDefined,
        'You must define Bullhorn::Config.collection_file'
      )
    end

    def collection
      @collection ||= load_collection
    end

    def env_collection
      @env_collection ||= load_env_collection
    end

    def registrate_channel(ch)
      registered_channels << ch.to_sym
    end

    private

    def load_collection
      notification_collection = YAML.load_file(collection_file)
      notification_collection.merge!(env_collection)
    end

    def load_env_collection
      if env_collection_file
        return YAML.load_file(env_collection_file) rescue { }
      end
      {}
    end
  end
end