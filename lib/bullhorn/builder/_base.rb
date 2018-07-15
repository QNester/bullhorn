module Bullhorn
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
        data.fetch(self.class.name.split('::').last.downcase)
      end

      def ch_options
        data.fetch('email', {})
      end
    end
  end
end