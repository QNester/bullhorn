require_relative '_base'

module Horn
  module Channels
    class Push < Base
      class << self
        def send!(builder, to:)
          options = {
            data: builder.push.data,
            notification: {
              title: builder.push.title,
              body: builder.push.body
            },
            priority: builder.options[:priority] || config.push.priority,
            time_to_live: config.push.ttl
          }
          p("[PUSH] Send #{options} body for #{ids(to)}")
          config.push.fcm.send(ids(to), options)
        end

        private

        def ids(to)
          return to if to.is_a?(Array)
          [to]
        end

        def required_credentials
          [:fcm_token]
        end
      end
    end
  end
end