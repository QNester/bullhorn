require 'spec_helper'

RSpec.describe HeyYou::DataSource::Yaml do
  describe 'attributes' do
    include_examples :have_readers, :collection_files, :env_collection_file
  end

  describe '#load_collections' do
    let(:file) { 'spec/fixtures/notifications.yml' }
    let(:options) { { collection_files: file } }
    subject { described_class.new(**options).load_collections }

    it 'load notifications into #collection' do
      expect(subject).to eq(YAML.load_file(file))
    end

    context 'with env_collection_file' do
      let(:env_file) { 'spec/fixtures/notifications_env.yml' }
      let(:options) { { collection_files: file,  env_collection_file: env_file } }

      it 'merge notifications into #collection' do
        expected_hash = YAML.load_file(file).merge(YAML.load_file(env_file))
        expect(subject).to eq(expected_hash)
      end
    end
  end
end