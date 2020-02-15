module HeyYou
  module DataSource
    class Base
      def load_notifications
        raise NotImplementedError
      end
    end
  end
end