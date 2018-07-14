require_relative '_base'

module Bullhorn
  class Builder
    class Sms < Base
      attr_reader :text

      def build
        @text = interpolate(data['sms']['text'], options)
      end
    end
  end
end