require 'spec_helper'

RSpec.describe HeyYou::Builder::Push do
  include_examples :have_readers, :body, :title, :data

  describe '#to_hash' do
    let!(:data) { { 'title' => 'hello', 'body' => 'hello, world' } }
    subject do
      described_class.new(data, 'test').to_hash
    end

    it 'returns subject and body' do
      expect(subject).to eq(title: data['title'], body: data['body'], data: {})
    end
  end
end