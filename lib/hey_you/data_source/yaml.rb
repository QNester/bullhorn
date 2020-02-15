require 'hey_you/data_source/_base'

module HeyYou
  module DataSource
    class Yaml < Base
      attr_reader :collection_files, :env_collection_file

      def initialize(collection_files:, env_collection_file: nil)
        @collection_files = collection_files
        @collection_files = [collection_files] if collection_files.is_a?(String)
        @env_collection_file = env_collection_file
      end

      # Load yaml from collection_file and merge it with yaml from env_collection_file
      def load_collections
        notification_collection = {}
        collection_files.each do |file|
          notification_collection.merge!(YAML.load_file(file))
        end
        notification_collection.merge!(env_collection)
      end

      def env_collection
        @env_collection ||= load_env_collection
      end

      private

      def load_env_collection
        if env_collection_file
          return YAML.load_file(env_collection_file) rescue { }
        end
        {}
      end
    end
  end
end