require 'spec_helper'

RSpec.describe HeyYou::Config do
  include_examples :singleton

  describe 'attributes' do
    include_examples(
      :have_accessors, :splitter, :registered_channels, :logger, :log_tag, :localization, :require_all_channels
    )
    include_examples :have_readers, :collection, :env_collection, :configured, :registered_receivers
  end

  describe '#configure' do
    before do
      described_class.instance_variable_set(:@configured, false)
    end

    describe 'splitter' do
      SPLITTER_VALUE = '--'

      before do
        HeyYou::Config.configure { config.splitter = SPLITTER_VALUE }
      end

      it 'returns splitter value' do
        expect(described_class.instance.splitter).to eq(SPLITTER_VALUE)
      end
    end

    describe 'data source' do
      FILENAME = 'spec/fixtures/notifications.yml'
      ENV_FILENAME = 'spec/fixtures/notifications_env.yml'

      context 'data source is yaml' do
        before do
          described_class.configure { config.data_source.options = { collection_files: [FILENAME] } }
        end

        it 'load notifications into #collection' do
          expect(described_class.instance.collection).to eq(YAML.load_file(FILENAME))
        end

        context 'with env_collection_file' do
          before do
            described_class.instance_variable_set(:@configured, false)
            described_class.instance.instance_variable_set(:@collection, nil)

            described_class.configure do
              config.data_source.options = {
                collection_files: [FILENAME],
                env_collection_file: ENV_FILENAME
              }
            end
          end

          it 'merge notifications into #collection' do
            expected_hash = YAML.load_file(FILENAME).merge(YAML.load_file(ENV_FILENAME))
            expect(described_class.instance.collection).to eq(expected_hash)
          end
        end
      end

      context 'data source is hash' do
        let!(:hash_with_texts) { YAML.load_file('spec/fixtures/notifications.yml').merge(data: true) }

        before do
          described_class.instance_variable_set(:@configured, false)
          described_class.instance.instance_variable_set(:@collection, nil)

          described_class.configure do
            config.data_source.source_class = HeyYou::DataSource::Hash
            config.data_source.options = { data: YAML.load_file('spec/fixtures/notifications.yml').merge(data: true) }
          end
        end

        it 'load notifications into #collection' do
          expect(described_class.instance.collection).to eq(hash_with_texts)
        end

        after do
          described_class.instance_variable_set(:@configured, false)
          described_class.instance.instance_variable_set(:@collection, nil)
          described_class.configure do
            config.data_source.source_class = HeyYou::DataSource::Yaml
            config.data_source.options = { collection_files: [FILENAME] }
          end
        end
      end
    end

    describe 'registered_channels' do
      before do |ex|
        unless ex.metadata[:skip_before]
          described_class.configure { config.registered_channels = [:push, :email] }
        end
      end

      it 'set registered channels' do
        expect(described_class.instance.registered_channels).to eq([:push, :email])
      end

      it 'define methods for all channels' do
        [:push, :email].each do |ch|
          found_method = described_class.instance.public_methods.find { |method| method == ch }
          expect(found_method).not_to eq(nil)
        end
      end

      context 'default channels' do
        it 'define method for all channels', :skip_before do
          HeyYou::Config::DEFAULTS[:registered_channels].each do |ch|
            found_method = described_class.instance.public_methods.find { |method| method == ch }
            expect(found_method).not_to eq(nil)
          end
        end
      end
    end
  end
end