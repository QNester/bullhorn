require_relative '_base'

module HeyYou
  module Channels
    class Push < Base
      class << self
        def send!(builder, to:, **options)
          options = build_options(builder)
          config.logger&.info("[PUSH] Send #{options} body for #{ids(to)}")
          config.push.fcm_client.send(ids(to), options)
        end

        private

        def build_options(builder)
          {
            data: builder.push.data,
            notification: {
              title: builder.push.title,
              body: builder.push.body
            },
            priority: builder.options[:priority] || config.push.priority,
            time_to_live: config.push.ttl
          }
        end

        def ids(to)
          return to if to.is_a?(Array)
          [to]
        end

        def required_credentials
          %i[fcm_token]
        end
      end
    end
  end
end