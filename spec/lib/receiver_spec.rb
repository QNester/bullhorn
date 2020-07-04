require 'spec_helper'
require 'dummy/user'
require 'byebug'

RSpec.describe User do
  before do
    HeyYou::Config.configure do
      config.data_source.options = { collection_files: [TEST_FILE] }
    end

    HeyYou::Config.instance.instance_variable_set(:@registered_channels, [:push, :email])
  end

  describe 'class method #receive' do
    subject { described_class.receive(receiver_options) }

    context 'pass not registered channel' do
      let!(:receiver_options) { { unknown_channel: -> { 'hello' } } }

      it 'raise NotRegisteredChannel' do
        expect { subject }.to raise_error(HeyYou::Receiver::NotRegisteredChannel)
      end
    end

    context 'pass registered channels' do
      let!(:user) { User.new }

      context 'without `if` condition' do
        let!(:receiver_options) { { push: -> { push_token.value } } }

        it 'registrate receiver in config' do
          subject
          expect(HeyYou::Config.instance.registered_receivers).to include(described_class)
        end

        it 'define receive methods' do
          subject
          expect(user.push_ch_receive_info).to eq(user.push_token.value)
          expect(user.push_ch_receive_condition).to eq(true)
          expect(user.push_ch_receive_options).to eq({})
        end
      end

      context 'receiver options with `if` falsey' do
        context 'if condition returns faley' do
          let!(:receiver_options) do
            {
              push: {
                subject: -> { push_token.value },
                if: -> { falsey_condition }
              }
            }
          end

          it 'receive_condition returns false' do
            subject
            expect(user.push_ch_receive_condition).to eq(false)
          end
        end

        context 'if condition returns truthy' do
          let!(:receiver_options) do
            {
              push: {
                subject: -> { push_token.value },
                if: -> { truthy_condition }
              }
            }
          end

          it 'receive_condition returns false' do
            subject
            expect(user.push_ch_receive_condition).to eq(true)
          end
        end
      end
    end
  end

  describe '#send_notification' do
    let!(:receiver_options) { { push: -> { push_token.value } } }
    let!(:user) { User.new }
    let!(:key) { 'rspec.test_notification' }
    let!(:options) { { force: true } }

    subject { user.send_notification(key, **options) }

    it 'call Sender send_to' do
      expect(HeyYou::Sender).to receive(:send_to).with(user, key, options)
      subject
    end

    context 'if condition returns falsey' do
      let!(:receiver_options) do
        {
          push: {
            subject: -> { push_token.value },
            if: -> { falsey_condition }
          }
        }
      end

      it 'doesnt send notification' do
        expect(HeyYou::Sender).to receive(:send_to).with(user, key, options)
        expect(HeyYou::Channels::Push).not_to receive(:send!)
        subject
      end
    end
  end
end