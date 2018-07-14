module Bullhorn
  module Channels
    class Base
      class << self
        def send!
          raise NotImplementedError, 'You should define #send! method in your channel.'
        end

        private

        def config
          Config.config
        end
      end
    end
  end
end