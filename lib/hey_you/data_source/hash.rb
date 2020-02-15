require 'hey_you/data_source/_base'

module HeyYou
  module DataSource
    class Hash < Base
      attr_reader :data

      def initialize(data:)
        @data = data
      end

      def load_collections
        data
      end
    end
  end
end