require 'yaml'
require 'hey_you/config/conigurable'
require 'hey_you/config/push'
require 'hey_you/config/email'

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
module HeyYou
  class Config
    extend Configurable

    DEFAULTS = {
      registered_channels: %i[email push],
      splitter: '.',
      log_tag: 'HeyYou',
      localization: false,
      require_all_channels: false
    }

    DEFAULT_REGISTERED_CHANNELS =
    DEFAULT_SPLITTER = '.'
    DEFAULT_GLOBAL_LOG_TAG = 'HeyYou'
    DEFAULT_LOCALIZATION_FLAG = false

    class CollectionFileNotDefined < StandardError; end

    attr_reader   :collection, :env_collection, :configured, :registered_receivers
    attr_accessor(
      :collection_files, :env_collection_file, :splitter,
      :registered_channels, :localization, :logger, :log_tag,
      :require_all_channels
    )

    def initialize
      @registered_channels ||= DEFAULTS[:registered_channels]
      @splitter ||= DEFAULTS[:splitter]
      @registered_receivers = []
      @log_tag ||= DEFAULTS[:log_tag]
      @localization ||= DEFAULTS[:localization]
      @require_all_channels = DEFAULTS[:require_all_channels]
      define_ch_config_methods
    end

    def collection_file
      @collection_files || raise(
        CollectionFileNotDefined,
        'You must define HeyYou::Config.collection_files'
      )
    end

    def collection
      @collection ||= load_collection
    end

    def env_collection
      @env_collection ||= load_env_collection
    end

    def registrate_receiver(receiver_class)
      log("#{receiver_class} registrated as receiver")
      @registered_receivers << receiver_class
    end

    # Registrate new custom channel.
    # For successful registration, in application must be exists:
    # 1. HeyYou::Channels::<YOUR_CHANNEL_NAME> < HeyYou::Channels::Base
    # 2. HeyYou::Builder::<YOUR_CHANNEL_NAME> < HeyYou::Builder::Base
    # 3. HeyYou::Config::<YOUR_CHANNEL_NAME> extended HeyYou::Config::Configurable
    #
    def registrate_channel(ch)
      registered_channels << ch.to_sym
      define_ch_config_method(ch)
    end

    def log(msg)
      logger&.info("[#{log_tag}] #{msg} ")
    end

    private

    def define_ch_config_methods
      registered_channels.each do |ch|
        define_ch_config_method(ch)
      end
    end

    # Define method for fetch config of channel.
    #
    # For example, if ch == 'push' will define method #push for class instance.
    # New method will return instance of channel config instance
    def define_ch_config_method(ch)
      method_proc = -> { self.class.const_get(ch.capitalize).config }
      self.class.send(:define_method, ch, method_proc)
    end

    # Load yaml from collection_file and merge it with yaml from env_collection_file
    def load_collection
      @collection_files = [collection_files] if collection_files.is_a?(String)
      notification_collection = {}
      collection_files.each do |file|
        notification_collection.merge!(YAML.load_file(file))
      end
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