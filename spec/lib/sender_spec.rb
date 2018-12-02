require 'spec_helper'
require 'dummy/user'
require 'dummy/rspec_mailer'

RSpec.describe HeyYou::Sender do
  let!(:channels) { [:push, :email] }
  let!(:key) { 'rspec.test_notification' }
  let!(:options) { { pass_variable: FFaker::Lorem.word } }

  let(:user) { User.new }
  let(:push_token) { user.push_token }

  before do
    HeyYou::Config.instance.instance_variable_set(:@registered_channels, channels)
    HeyYou::Config.instance.instance_variable_set(:@splitter, '.')
    HeyYou::Config.configure do
      config.collection_files = TEST_FILE
    end
  end

  describe 'class method #send_to' do
    before(:all) do
      User.receive({ push: -> { push_token.value } })
    end

    subject do
      described_class.send_to(receiver, key, **options)
    end

    context 'invalid receiver' do
      let!(:receiver) { push_token }

      it 'raise error NotRegisteredReceiver' do
        expect { subject }.to raise_error(HeyYou::Sender::NotRegisteredReceiver)
      end
    end

    context 'valid receiver' do
      let!(:receiver) { user }

      it 'call send!' do
        expect(described_class).to receive(:send!).with(key, user, **options)
        subject
      end
    end
  end

  describe 'class method #send!' do
    before(:all) do
      User.receive(
        push: -> { push_token.value },
        email: { subject: -> { email[:address] }, options: { mailer_class: RspecMailer } }
      )
    end

    let!(:to) do
      {
        push: { subject: user.push_token.value, options: {} },
        email: { subject: user.email[:address], options: { mailer_class: RspecMailer } }
      }
    end

    subject { described_class.send!(key, user, **options) }

    it 'call channel\'s #send! for each allowed registered channel' do
      channels.each do |ch|
        expect(HeyYou::Channels.const_get(ch.to_s.capitalize)).to(
          receive(:send!).with(instance_of(HeyYou::Builder), to: to[ch][:subject], **to[ch][:options])
        )
      end

      subject
    end

    context 'pass only options' do
      before { options[:only] = channels.sample }
      let!(:excluded_channels) { channels - [options[:only]] }

      it 'send for channel from only and not send for channel not from only' do
        expect(HeyYou::Channels.const_get(options[:only].to_s.capitalize)).to receive(:send!)

        excluded_channels.each do |ch|
          expect(HeyYou::Channels.const_get(ch.to_s.capitalize)).not_to receive(:send!)
        end
        subject
      end
    end
  end
end