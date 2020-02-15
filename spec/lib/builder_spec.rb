require 'spec_helper'

RSpec.describe HeyYou::Builder do
  before do
    HeyYou::Config.instance.instance_variable_set(:@splitter, '.')
    HeyYou::Config.configure do
      config.data_source.options = { collection_files: [TEST_FILE] }
      config.require_all_channels = true
    end
  end

  describe '#new' do
    let!(:key) { 'rspec.test_notification' }

    subject { described_class.new(key, options) }

    context 'pass options for interpolate' do
      let!(:pass_variable) { SecureRandom.uuid }
      let!(:options) { { pass_variable: pass_variable } }

      it 'define channels methods' do
        HeyYou::Config.instance.registered_channels.each do |ch|
          expected_class = described_class.const_get(ch.downcase.capitalize)
          expect(subject.send(ch)).to be_instance_of(expected_class)
        end
      end

      it 'set data with templates' do
        expect(subject.data).to be_instance_of(Hash)
      end
    end

    context 'not pass options for interpolate' do
      let!(:options) { {} }

      it 'raise error InterpolationError' do
        expect { subject }.to raise_error(HeyYou::Builder::Base::InterpolationError)
      end
    end

    context 'localization options is true' do
      let!(:key) { 'rspec.test_notification' }
      let!(:pass_variable) { SecureRandom.uuid }
      let!(:options) { { pass_variable: pass_variable } }

      before do
        HeyYou::Config.instance.instance_variable_set(:@localization, true)
      end

      after do
        HeyYou::Config.instance.instance_variable_set(:@localization, false)
      end

      context 'pass locale options' do
        before { options.merge!(locale: :ru) }

        it 'build data for locale' do
          expect(subject.data).to be_instance_of(Hash)
          expect(subject.data['push']['title']).to match('RU')
        end
      end

      context 'locale option not pass' do
        it 'build data for locale' do
          expect(subject.data).to be_instance_of(Hash)
          expect(subject.data['push']['title']).to match(I18n.locale.to_s.upcase)
        end
      end
    end

    context 'data for channel not exists' do
      let!(:pass_variable) { SecureRandom.uuid }
      let!(:key) { 'rspec.test_notification_no_push' }
      let!(:options) { { pass_variable: pass_variable } }

      context 'config.require_all_channels is true' do
        before do
          allow(HeyYou::Config.instance).to receive(:require_all_channels).and_return(true)
        end

        it 'raise RequiredChannelNotFound' do
          expect { subject }.to raise_error(HeyYou::Builder::RequiredChannelNotFound)
        end
      end

      context 'config.require_all_channels is false' do
        before do
          allow(HeyYou::Config.instance).to receive(:require_all_channels).and_return(false)
        end

        it 'build email channel' do
          expected_class = described_class::Email
          expect(subject.email).to be_instance_of(expected_class)
        end

        # Flow-broken test. I have no idea how to fix it.
        # If you are seeing it and wanna fix flow-bugget test:
        # remove begin block anduse seed 32560
        # Sorry :(
        it 'raise when build push channel' do
          expect(subject.push).to eq(nil)
        end
      end
    end

    context 'data key not exists' do
      let!(:key) { "#{FFaker::Lorem.word}.#{FFaker::Lorem.word}" }
      let!(:options) { {} }

      it 'raise DataNotFound error' do
        expect { subject }.to raise_error(described_class::DataNotFound)
      end
    end
  end
end