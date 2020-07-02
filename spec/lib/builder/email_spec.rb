require 'spec_helper'

RSpec.describe HeyYou::Builder::Email do
  include_examples :have_readers, :subject, :body, :layout, :mailer_class, :mailer_method

  describe '#to_hash' do
    let!(:data) { { 'subject' => 'hello', 'body' => 'hello, world' } }
    subject do
      described_class.new(data, 'test').to_hash
    end

    it 'returns subject and body' do
      expect(subject).to eq(subject: data['subject'], body: data['body'])
    end
  end
end