module HeyYou
  class Builder
    class Base
      INTERPOLATION_PATTERN = Regexp.union(
        /%%/,
        /%\{(\w+)\}/, # matches placeholders like "%{foo}"
      )

      attr_reader :data, :key, :options

      def initialize(data, key, **options)
        @data = data
        @key = key
        @options = options
        build
      end

      private

      def interpolate(notification_string, options)
        notification_string % options
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
    end
  end
end