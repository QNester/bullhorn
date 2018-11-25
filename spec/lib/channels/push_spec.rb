require 'spec_helper'

RSpec.describe HeyYou::Channels::Push do
  before do
    HeyYou::Config.instance.instance_variable_set(:@splitter, '.')
    HeyYou::Config.configure do
      config.collection_file = TEST_FILE
    end
  end

  let!(:user_token) { SecureRandom.uuid }
  let!(:builder) { HeyYou::Builder.new('rspec.test_notification', pass_variable: FFaker::Lorem.word) }

  describe 'send!' do
    subject { described_class.send!(builder, to: user_token) }

    context 'all credentials presents' do
      before do
        HeyYou::Config.instance.push.fcm_token = SecureRandom.uuid
      end

      it 'send msg via fcm' do
        expect(HeyYou::Config.instance.push.fcm_client).to(
          receive(:send).with(
            [user_token],
            hash_including(
              data: {},
              notification: hash_including(:title, :body),
              priority: HeyYou::Config.instance.push.priority,
              time_to_live: HeyYou::Config.instance.push.ttl
            )
          ).and_return(true)
        )
        subject
      end
    end

    context 'not all credentials presents' do
      before do
        HeyYou::Config.instance.push.fcm_token = nil
      end

      it 'raise error' do
        expect { subject }.to raise_error(HeyYou::Config::Push::FcmTokenNotExists)
      end
    end
  end
end