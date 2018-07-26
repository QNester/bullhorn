require 'spec_helper'

RSpec.describe Bullhorn::Config::Sms do
  before do
    described_class.instance.instance_variable_set(:@configured, false)
    described_class.instance.instance_variable_set(:@twilio_account_sid, nil)
    described_class.instance.instance_variable_set(:@twilio_auth_token, nil)
    described_class.instance.instance_variable_set(:@twilio_from_number, nil)
  end

  include_examples :singleton

  describe 'attributes' do
    include_examples :have_accessors, :twilio_account_sid, :twilio_auth_token, :twilio_from_number
    include_examples :have_readers, :twilio_client
  end

  describe '#twilio_client' do
    subject { described_class.instance.twilio_client }

    context 'pass twilio credentials' do
      before do
        described_class.configure do
          config.twilio_account_sid = SecureRandom.uuid
          config.twilio_auth_token = SecureRandom.uuid
          config.twilio_from_number = rand
        end
      end

      it 'returns instance of FCM' do
        expect(subject).to be_instance_of(Twilio::REST::Client)
      end
    end

    context 'not pass twilio credentials' do
      it 'raise TwilioCredentialsNotExists' do
        expect { subject }.to raise_error(Bullhorn::Config::Sms::TwilioCredentialsNotExists)
      end
    end
  end
end