require 'spec_helper'

RSpec.describe HeyYou::Channels::Email do
  before do
    HeyYou::Config.instance.instance_variable_set(:@splitter, '.')
    HeyYou::Config.configure do
      config.collection_file = TEST_FILE
    end
  end

  describe 'send!' do
    let!(:from) { FFaker::Internet.email }
    let!(:user_email) { FFaker::Internet.email }
    let!(:builder) { HeyYou::Builder.new('rspec.test_notification', pass_variable: FFaker::Lorem.word) }

    subject { described_class.send!(builder, to: user_email) }

    context 'all credentials presents' do
      before do
        HeyYou::Config.instance.email.from = from
        HeyYou::Config.instance.email.delivery_method = :test
      end

      it 'send email' do
        expect { subject }.to change(Mail::TestMailer.deliveries, :length).by(1)
        msg = Mail::TestMailer.deliveries.last
        expect(msg.from.first).to eq(from)
        expect(msg.to.first).to eq(user_email)
        expect(msg.subject).to match(/Test/)
        expect(msg.body.to_s).to match(/Test/)
      end
    end

    context 'not all credentials presents' do
      before do
        HeyYou::Config.instance.email.from = nil
      end

      it 'raise error' do
        expect { subject }.to raise_error(described_class::CredentialsNotExists)
      end
    end
  end
end