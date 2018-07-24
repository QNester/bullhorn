require 'spec_helper'

RSpec.describe Bullhorn::Config do
  describe 'must be singleton' do
    it 'have #instance method and return instance' do
      expect(described_class.instance).to be_instance_of(Bullhorn::Config)
    end

    it 'new is private method' do
      expect { described_class.new }.to raise_error(NoMethodError)
    end
  end

  describe '#configure' do
    before do
      described_class.instance_variable_set(:@configured, false)
    end

    describe 'splitter' do
      SPLITTER_VALUE = '--'

      before do
        Bullhorn::Config.configure { config.splitter = SPLITTER_VALUE }
      end

      it 'returns splitter value' do
        expect(described_class.instance.splitter).to eq(SPLITTER_VALUE)
      end
    end

    describe 'collection_file' do
      FILENAME = 'spec/fixtures/notifications.yml'
      ENV_FILENAME = 'spec/fixtures/notifications_env.yml'

      before do
        described_class.configure { config.collection_file = FILENAME }
      end

      it 'return collection file path' do
        expect(described_class.instance.collection_file).to eq(FILENAME)
      end

      it 'load notifications into #collection' do
        expect(described_class.instance.collection).to eq(YAML.load_file(FILENAME))
      end

      context 'with env_collection_file' do
        before do
          described_class.instance_variable_set(:@configured, false)
          described_class.instance.instance_variable_set(:@collection, nil)
          described_class.instance.instance_variable_set(:@env_collection, nil)

          described_class.configure do
            config.collection_file = FILENAME
            config.env_collection_file = ENV_FILENAME
          end
        end

        it 'merge notifications into #collection' do
          expected_hash = YAML.load_file(FILENAME).merge(YAML.load_file(ENV_FILENAME))
          expect(described_class.instance.collection).to eq(expected_hash)
        end
      end
    end

    describe 'registered_channels' do

    end

    describe 'push' do
      describe 'fcm_token' do

      end
    end

    describe 'email' do
      describe 'from' do

      end
    end
  end
end