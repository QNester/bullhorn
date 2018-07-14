require_relative '_base'

module Bullhorn
  class Builder
    class Push < Base
      attr_reader :body, :title, :data

      def build
        @title = interpolate(ch_data.fetch('title'), options)
        @body = interpolate(ch_data.fetch('body'), options)
        @data = options[:data] || {}
      end
    end
  end
end