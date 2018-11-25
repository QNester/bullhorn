require 'spec_helper'
require 'dummy/user'

RSpec.describe HeyYou::Sender do
  let!(:channels) { [:push, :email] }
  let!(:key) { 'rspec.test_notification' }
  let!(:options) { { pass_variable: FFaker::Lorem.word } }

  before do
    HeyYou::Config.instance.instance_variable_set(:@registered_channels, channels)
    HeyYou::Config.instance.instance_variable_set(:@splitter, '.')
    HeyYou::Config.configure do
      config.collection_file = TEST_FILE
    end
  end

  describe 'class method #send_to' do
    let!(:receiver_options) { { push: -> { push_token.value } } }
    before do
      User.receive(receiver_options)
    end
    let!(:user) { User.new }
    let!(:push_token) { user.push_token }

    subject { described_class.send_to(receiver, key, **options) }

    context 'invalid receiver' do
      let!(:receiver) { push_token }

      it 'raise error NotRegisteredReceiver' do
        expect { subject }.to raise_error(HeyYou::Sender::NotRegisteredReceiver)
      end
    end

    context 'valid receiver' do
      let!(:receiver) { user }

      it 'call send!' do
        expected_to = {
          push: user.push_token.value
        }
        expect(described_class).to receive(:send!).with(key, to: expected_to, **options)
        subject
      end
    end
  end

  describe 'class method #send!' do
    let!(:to) do
      {
        sms: FFaker::PhoneNumber.phone_number,
        push: SecureRandom.uuid,
        email: FFaker::Internet.email
      }
    end

    subject { described_class.send!(key, to: to, **options) }

    it 'call channel\'s #send! for each allowed registered channel' do
      channels.each do |ch|
        expect(HeyYou::Channels.const_get(ch.to_s.capitalize)).to(
          receive(:send!).with(instance_of(HeyYou::Builder), to: to[ch])
        )
      end

      subject
    end

    context 'pass only options' do
      before { options[:only] = channels.sample }
      let!(:excluded_channels) { channels - [options[:only]] }

      it 'send for channel from only and not send for channel not from only' do
        expect(HeyYou::Channels.const_get(options[:only].to_s.capitalize)).to(
          receive(:send!).with(instance_of(HeyYou::Builder), to: to[options[:only]])
        )

        excluded_channels.each do |ch|
          expect(HeyYou::Channels.const_get(ch.to_s.capitalize)).not_to receive(:send!)
        end
        subject
      end
    end
  end
end