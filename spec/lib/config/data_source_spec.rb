require 'spec_helper'

RSpec.describe HeyYou::Config::DataSource do
  include_examples :singleton

  describe 'attributes' do
    include_examples :have_accessors, :source_class, :options, :source_instance
  end

  describe '#load_data' do
    subject do
      described_class.instance.load_data
    end

    context 'source instance was passed' do
      let!(:source_instance) { HeyYou::DataSource::Yaml.new(collection_files: 'spec/fixtures/notifications.yml') }
      before { described_class.instance.source_instance = source_instance }

      it 'call load_collections for source_instance' do
        expect(source_instance).to receive(:load_collections).and_return({})
        subject
      end

      it 'returns data from source_instance' do
        expect(subject).to eq(source_instance.load_collections)
      end
    end

    context 'source klass was passed' do
      context 'options without required arguments' do
        before do
          described_class.instance.source_instance = nil
          described_class.instance.source_class = HeyYou::DataSource::Yaml
          described_class.instance.options = { collection_files: 'spec/fixtures/notifications.yml' }
        end

        it 'create instance of source class with options' do
          expect(described_class.instance.source_class).to receive(:new)
            .with(described_class.instance.options).and_return(double(load_collections: {}))
          subject
        end

        it 'call load_collections for source class' do
          expect_any_instance_of(described_class.instance.source_class).to receive(:load_collections).and_return({})
          subject
        end
      end
    end
  end
end