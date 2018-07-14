require_relative 'builder/email'
require_relative 'builder/push'
require_relative 'builder/sms'

module Bullhorn
  class Builder
    attr_reader :data, :options

    def initialize(key, **options)
      @data = fetch_from_collection_by_key(key)
      @options = options
      config.registered_channels.each do |ch|
        ch_builder =
          Bullhorn::Builder.const_get("#{ch.downcase.capitalize}").new(data, key, options)
        instance_variable_set("@#{ch}".to_sym, ch_builder)

        define_ch_method(ch)
      end
    end

    private

    def define_ch_method(ch)
      method_proc = -> { instance_variable_get("@#{ch}".to_sym) }
      self.class.send(:define_method, ch, method_proc)
    end

    def fetch_from_collection_by_key(key)
      keys = key.to_s.split(config.splitter)
      keys.reduce(config.collection) do |memo, nested_key|
        memo[nested_key.to_s] if memo
      end
    end

    def config
      Config.config
    end
  end
end