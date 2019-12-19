module HeyYou
  class Builder
    class Base
      attr_reader :data, :key, :options

      def initialize(data, key, **options)
        @data = data
        @key = key
        @options = options
        build
      end

      def to_hash
        raise NotImplementedError, 'Builder not implemented #to_hash method'
      end
      alias_method :to_h, :to_hash

      private

      def interpolate(notification_string, options)
        notification_string % options
      rescue KeyError => err
        raise InterpolationError, "Failed build notification string `#{notification_string}`: #{err.message}"
      end

      def ch_data
        data.fetch(current_builder_name)
      end

      alias channel_data ch_data

      def ch_options
        options.fetch(current_builder_name, {})
      end

      alias channel_options ch_options

      def current_builder_name
        self.class.name.split('::').last.downcase
      end

      class InterpolationError < StandardError; end
    end
  end
end