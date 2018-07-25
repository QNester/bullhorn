require 'yaml'
require_relative 'config/conigurable'
require_relative 'config/sms'
require_relative 'config/push'
require_relative 'config/email'

#
# @config REQUIRED collection_file [String] - File path for general notifications file
# @config OPTIONAL env_collection_file [String] - File path for environment notifications file
# @config OPTIONAL splitter [String] - Chars for split notifications keys in builder.
#   For example:
#     if splitter eq `.` you can pass to notification builder 'key_1.nested_key'
#     if splitter eq `/` you can pass to notification builder 'key_1/nested_key'
# @config OPTIONAL registered_channels - Channels available for service. If your application
#   planning use only push and email just set it as [:push, :email]. Default all channels
#   will available.
module Bullhorn
  class Config
    extend Configurable

    DEFAULT_REGISTERED_CHANNELS = %i[sms email push]
    DEFAULT_SPLITTER = '.'
    class CollectionFileNotDefined < StandardError; end

    attr_reader   :collection, :env_collection, :configured, :registered_receivers
    attr_accessor :collection_file, :env_collection_file, :splitter, :registered_channels

    def initialize
      @registered_channels ||= DEFAULT_REGISTERED_CHANNELS
      @splitter ||= DEFAULT_SPLITTER
      @registered_receivers = []
      define_ch_config_methods
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

    def registrate_receiver(receiver_class)
      @registered_receivers << receiver_class
    end

    # Registrate new custom channel.
    # For successful registration, in application must be exists:
    # 1. Bullhorn::Channels::<YOUR_CHANNEL_NAME> < Bullhorn::Channels::Base
    # 2. Bullhorn::Builder::<YOUR_CHANNEL_NAME> < Bullhorn::Builder::Base
    # 3. Bullhorn::Config::<YOUR_CHANNEL_NAME> extended Bullhorn::Config::Configurable
    #
    def registrate_channel(ch)
      registered_channels << ch.to_sym
      define_ch_config_method(ch)
    end

    private

    def define_ch_config_methods
      registered_channels.each do |ch|
        define_ch_config_method(ch)
      end
    end

    # Define method for fetch config of channel.
    #
    # For example, if ch == 'sms' will define method #sms for class instance.
    # New method will return instance of channel config instance
    def define_ch_config_method(ch)
      method_proc = -> { self.class.const_get(ch.capitalize).config }
      self.class.send(:define_method, ch, method_proc)
    end

    # Load yaml from collection_file and merge it with yaml from env_collection_file
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