require 'hey_you/config/conigurable'
require 'hey_you/data_source/yaml'
require 'hey_you/data_source/hash'

module HeyYou
  class Config
    class DataSource
      extend Configurable

      attr_accessor :source_class, :options, :source_instance

      def initialize
        @type = DEFAULTS[:type]
        @options = DEFAULTS[:options]
        @source_class = HeyYou::DataSource::Yaml
      end

      def load_data
        return source_instance.load_collections if source_instance

        if source_class.nil?
          raise InvalidDataSourceError, 'You must pass `config.data_source.source_class` in configuration.'
        end

        source_class.new(options).load_collections
      rescue ArgumentError => err
        problem_fields =
          err.message.gsub(/missing keyword(.?):\s/, '').split(', ').map { |f| "`#{f}`" }.join(', ')
        field_word = problem_fields.split(', ').size > 1 ? 'fields' : 'field'
        msg = "You must pass #{field_word} #{problem_fields} for `config.data_source.options` in configuration"

        raise InvalidOptionsError, msg
      end

      class InvalidOptionsError < StandardError; end
    end
  end
end