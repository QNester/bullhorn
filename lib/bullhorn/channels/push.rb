require_relative '_base'

module Bullhorn
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
          response = config.push.fcm.send(ids(to), options)
          p response
        end

        private

        def ids(to)
          return to if to.is_a?(Array)
          [to]
        end
      end
    end
  end
end