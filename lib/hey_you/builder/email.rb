require_relative '_base'

module HeyYou
  class Builder
    class Email < Base
      attr_reader :subject, :body, :layout, :mailer_class, :mailer_method, :delivery_method

      def build
        @mailer_class = ch_data.fetch('mailer_class', nil)
        @mailer_method = ch_data.fetch('mailer_method', nil)
        @delivery_method = ch_data.fetch('delivery_method', nil)
        @body = interpolate(ch_data.fetch('body'), options)
        @subject = interpolate(ch_data.fetch('subject'), options)
      end

      def to_hash
        { body: body, subject: subject }
      end
    end
  end
end