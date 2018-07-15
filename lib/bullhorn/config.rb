require 'yaml'
require_relative 'mixins/conigurable'
require_relative 'config/sms'
require_relative 'config/push'
require_relative 'config/email'

module Bullhorn
  class Config
    extend ::Bullhorn::Mixins::Configurable

    DEFAULT_REGISTERED_CHANNELS = %i[sms email push]
    DEFAULT_SPLITTER = '.'

    attr_reader :collection, :env_collection, :configured, :registered_receivers
    attr_writer :collection_file
    attr_accessor :env_collection_file, :splitter, :registered_channels

    def initialize
      @registered_channels = DEFAULT_REGISTERED_CHANNELS
      @splitter = DEFAULT_SPLITTER
      @registered_receivers = []
      define_ch_config_methods
    end

    def define_ch_config_methods
      registered_channels.each do |ch|
        define_ch_config_method(ch)
      end
    end

    def define_ch_config_method(ch)
      method_proc = -> { self.class.const_get(ch.capitalize).config }
      self.class.send(:define_method, ch, method_proc)
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
      define_ch_config_method(ch)
    end

    def registrate_receiver(receiver_class)
      @registered_receivers << receiver_class
    end

    class CollectionFileNotDefined < StandardError; end

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