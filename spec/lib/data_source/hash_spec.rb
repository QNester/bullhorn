require 'spec_helper'

RSpec.describe HeyYou::DataSource::Hash do
  describe 'attributes' do
    include_examples :have_readers, :data
  end

  describe '#load_collections' do
    let!(:hash_with_texts) { YAML.load_file('spec/fixtures/notifications.yml').merge(data: true) }
    let(:options) { { data: hash_with_texts } }
    subject { described_class.new(**options).load_collections }

    it 'load notifications into #collection' do
      expect(subject).to eq(hash_with_texts)
    end
  end
end