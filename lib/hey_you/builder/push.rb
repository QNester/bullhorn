require_relative '_base'

module HeyYou
  class Builder
    class Push < Base
      attr_reader :body, :title, :data

      def build
        @title = interpolate(ch_data.fetch('title'), options)
        @body = interpolate(ch_data.fetch('body'), options)
        @data = options[:data] || {}
      end

      def to_hash
        { title: title, body: body, data: data }
      end
    end
  end
end