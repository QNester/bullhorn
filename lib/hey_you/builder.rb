require 'i18n'
require 'hey_you/helper'
require 'hey_you/builder/email'
require 'hey_you/builder/push'

module HeyYou
  class Builder
    include HeyYou::Helper

    attr_reader :data, :options, :keys

    # Load data from collection yaml via key and interpolate variables.
    # Define methods for each registered channel. After initialize you can use
    #   `instance.<ch_name>`. It will be return instance of HeyYou::Builder::<YOUR_CHANNEL_NAME>
    #
    # Skip builder for excluded channels (not included in `only` option)
    #
    # @param [String] key - notification key for fetching notification data from collection
    def initialize(key, **options)
      @data = fetch_from_collection_by_key(key, options[:locale])
      @options = options
      config.registered_channels.each do |ch|
        init_channel_builder(ch, key) if channel_allowed_by_only?(ch, options[:only])
      end
    end

    private

    def init_channel_builder(ch, key)
      if config.require_all_channels
        unless data[ch.to_s]
          raise RequiredChannelNotFound, "For key #{key} and channel #{ch} data not exists in collection."
        end
      end
      unless data[ch.to_s]
        define_ch_method(ch, true)
        return
      end

      klass_name = ch.to_s.downcase.split('_').map(&:capitalize).join
      ch_builder = HeyYou::Builder.const_get(klass_name).new(data[ch.to_s], key, **options)
      instance_variable_set("@#{ch}".to_sym, ch_builder)

      define_ch_method(ch)
    end

    def define_ch_method(ch, empty = false)
      method_proc = empty ? -> { nil } : -> { instance_variable_get("@#{ch}".to_sym) }
      self.class.send(:define_method, ch, method_proc)
    end

    def fetch_from_collection_by_key(key, locale)
      keys = []
      if config.localization
        locale = locale || I18n.locale
        raise UnknownLocale, 'You should pass locale.' unless locale
        keys << locale
      end
      keys = keys + key.to_s.split(config.splitter)
      data = keys.reduce(config.collection) do |memo, nested_key|
        memo[nested_key.to_s] if memo
      end
      return data if data
      raise DataNotFound, "collection data not found for `#{keys.join(config.splitter)}`"
    end

    def channel_allowed_by_only?(ch, only)
      return true unless only
      return only.map(&:to_sym).include?(ch.to_sym) if only.is_a?(Array)
      only.to_sym == ch.to_sym
    end

    class UnknownLocale < StandardError; end
    class DataNotFound < StandardError; end
    class RequiredChannelNotFound < StandardError; end
  end
end
