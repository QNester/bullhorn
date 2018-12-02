require 'spec_helper'

RSpec.describe HeyYou::Builder do
  before do
    HeyYou::Config.instance.instance_variable_set(:@splitter, '.')
    HeyYou::Config.configure do
      config.collection_files = TEST_FILE
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

    context 'not pass options for interpolate', focus: true do
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
  end
end