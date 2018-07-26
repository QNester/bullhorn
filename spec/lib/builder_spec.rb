require 'spec_helper'

RSpec.describe Bullhorn::Builder do
  TEST_FILE = 'spec/fixtures/notifications.yml'

  before do
    Bullhorn::Config.instance.instance_variable_set(:@splitter, '.')
    Bullhorn::Config.configure do
      config.collection_file = TEST_FILE
    end
  end

  describe '#new' do
    let!(:key) { 'rspec.test_notification' }
    subject { described_class.new(key, options) }

    context 'pass options for interpolate' do
      let!(:pass_variable) { SecureRandom.uuid }
      let!(:options) { { pass_variable: pass_variable } }

      it 'define channels methods' do
        Bullhorn::Config.instance.registered_channels.each do |ch|
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

      it 'define channels methods' do
        expect { subject }.to raise_error(KeyError)
      end
    end
  end
end