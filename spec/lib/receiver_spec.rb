require 'spec_helper'
require 'dummy/user'

RSpec.describe User do
  before do
    Horn::Config.configure do
      config.collection_file = TEST_FILE
    end

    Horn::Config.instance.instance_variable_set(:@registered_channels, [:sms, :push, :email])
  end

  describe 'class method #receive' do
    subject { described_class.receive(receiver_options) }

    context 'pass not registered channel' do
      let!(:receiver_options) { { unknown_channel:  -> { 'hello' } } }

      it 'raise NotRegisteredChannel' do
        expect { subject }.to raise_error(Horn::Receiver::NotRegisteredChannel)
      end
    end

    context 'pass registered channels' do
      let!(:receiver_options) { { sms: -> { number }, push: -> { push_token.value } } }
      let!(:user) { User.new }

      it 'registrate receiver in config' do
        subject
        expect(Horn::Config.instance.registered_receivers).to include(described_class)
      end

      it 'define receive methods' do
        subject
        expect(user.sms_ch_receive_info).to eq(user.number)
        expect(user.push_ch_receive_info).to eq(user.push_token.value)
      end
    end
  end

  describe '#send_notification' do
    let!(:receiver_options) { { sms: -> { number }, push: -> { push_token.value } } }
    let!(:user) { User.new }
    let!(:key) { 'rspec.test_notification' }

    subject { user.send_notification(key, {}) }

    it 'call Sender send_to' do
      expect(Horn::Sender).to receive(:send_to).with(user, key, {})
      subject
    end
  end
end