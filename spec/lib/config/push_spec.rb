require 'spec_helper'

RSpec.describe HeyYou::Config::Push do
  before do
    described_class.instance.instance_variable_set(:@configured, false)
    described_class.instance.instance_variable_set(:@fcm_token, nil)
  end

  include_examples :singleton

  describe 'attributes' do
    include_examples :have_accessors, :fcm_token, :priority, :ttl, :fcm_timeout
  end

  describe '#fcm_client' do
    subject { described_class.instance.fcm_client }

    context 'pass fcm token' do
      before { described_class.configure { config.fcm_token = SecureRandom.uuid } }

      it 'returns instance of FCM' do
        expect(subject).to be_instance_of(FCM)
      end
    end

    context 'not pass fcm token' do
      it 'raise FcmTokenNotExists' do
        expect { subject }.to raise_error(HeyYou::Config::Push::FcmTokenNotExists)
      end
    end
  end
end