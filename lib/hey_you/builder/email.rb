require_relative '_base'

module HeyYou
  class Builder
    class Email < Base
      attr_reader :subject, :body, :layout, :mailer_class, :mailer_method, :delivery_method, :body_parts

      def build
        @mailer_class = ch_data.fetch('mailer_class', nil)
        @mailer_method = ch_data.fetch('mailer_method', nil)
        @delivery_method = ch_data.fetch('delivery_method', nil)
        @body = interpolate(ch_data['body'], options) if ch_data['body']
        @body_parts = interpolate_each(ch_data.fetch('body_parts', nil), options)
        @subject = interpolate(ch_data.fetch('subject'), options)
      end

      def to_hash
        { body: body, subject: subject, body_parts: body_parts }
      end

      private

      def interpolate_each(notification_hash, options)
        return notification_hash unless notification_hash.is_a?(Hash)

        notification_hash.each do |k, v|
          next interpolate_each(v, options) if v.is_a?(Hash)

          begin
            notification_hash[k] = v % options
          rescue KeyError
            raise InterpolationError, "Failed build notification string `#{v}`: #{err.message}"
          end
        end
      end
    end
  end
end
