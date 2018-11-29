require 'spec_helper'
require 'dummy/rspec_mailer'

RSpec.describe HeyYou::Channels::Email do
  let(:mailer_class) { RspecMailer }
  let(:mailer_method) { :welcome }
  let(:mailer_msg) { double('mailer_msg', deliver_now: true, deliver_later: true) }

  before do
    HeyYou::Config.instance.instance_variable_set(:@splitter, '.')
    HeyYou::Config.configure do
      config.collection_file = TEST_FILE
    end
  end

  describe 'send!' do
    let!(:from) { FFaker::Internet.email }
    let!(:user_email) { FFaker::Internet.email }
    let!(:builder) { HeyYou::Builder.new('rspec.test_notification', pass_variable: FFaker::Lorem.word) }

    subject { described_class.send!(builder, to: user_email) }

    context 'not default mailer' do
      before do
        HeyYou::Config.instance.email.from = from
        HeyYou::Config::Email.instance.instance_variable_set(:@default_mailing, false)
      end

      context 'set mailer_class' do
        context 'set mailer_class via builder' do
          let!(:builder) { HeyYou::Builder.new('rspec.test_notification_with_mailer_class', pass_variable: FFaker::Lorem.word) }

          context 'mailer_method set via default in config' do
            before { HeyYou::Config.instance.email.default_mailer_method = mailer_method }

            it 'call mailer_class mailer_method' do
              expect(mailer_class).to receive(mailer_method).once.and_return(mailer_msg)
              subject
            end
          end

          context 'mailer_method set via builder' do
            let!(:builder) { HeyYou::Builder.new('rspec.test_notification_with_mailer', pass_variable: FFaker::Lorem.word) }

            it 'call mailer_class mailer_method' do
              expect(mailer_class).to receive(mailer_method).once.and_return(mailer_msg)
              subject
            end
          end

          context 'mailer_method set via option' do
            subject { described_class.send!(builder, to: user_email, mailer_method: mailer_method) }

            it 'call mailer_class mailer_method' do
              expect(mailer_class).to receive(mailer_method).once.and_return(mailer_msg)
              subject
            end
          end

          context 'mailer_method not set' do
            before do
              HeyYou::Config::Email.instance.instance_variable_set(
                :@default_mailer_method, HeyYou::Config::Email::DEFAULT_ACTION_MAILER_METHOD
              )
            end

            it 'call mailer_class#send!' do
              expect(mailer_class).to receive(:send!).once.and_return(mailer_msg)
              subject
            end
          end
        end

        context 'set mailer_class via option' do
          subject { described_class.send!(builder, to: user_email, mailer_class: mailer_class) }

          context 'mailer_method set via default in config' do
            before { HeyYou::Config.instance.email.default_mailer_method = mailer_method }

            it 'call mailer_class mailer_method' do
              expect(mailer_class).to receive(mailer_method).once.and_return(mailer_msg)
              subject
            end
          end

          context 'mailer_method set via builder' do
            let!(:builder) { HeyYou::Builder.new('rspec.test_notification_with_mailer_method', pass_variable: FFaker::Lorem.word) }

            it 'call mailer_class mailer_method' do
              expect(mailer_class).to receive(mailer_method).once.and_return(mailer_msg)
              subject
            end
          end

          context 'mailer_method set via option' do
            subject { described_class.send!(builder, to: user_email, mailer_class: mailer_class, mailer_method: mailer_method) }

            it 'call mailer_class mailer_method' do
              expect(mailer_class).to receive(mailer_method).once.and_return(mailer_msg)
              subject
            end
          end

          context 'mailer_method not set' do
            let!(:builder) { HeyYou::Builder.new('rspec.test_notification', pass_variable: FFaker::Lorem.word) }
            before do
              HeyYou::Config::Email.instance.instance_variable_set(
                :@default_mailer_method, HeyYou::Config::Email::DEFAULT_ACTION_MAILER_METHOD
              )
            end

            it 'call mailer_class#send!' do
              expect(mailer_class).to receive(:send!).once.and_return(mailer_msg)
              subject
            end
          end
        end

        context 'set mailer_class via default_config' do
          before do
            HeyYou::Config.instance.email.default_mailer_class = mailer_class
          end

          after do
            HeyYou::Config.instance.email.default_mailer_class = nil
          end

          context 'mailer_method set via default in config' do
            before { HeyYou::Config.instance.email.default_mailer_method = mailer_method }

            it 'call mailer_class mailer_method' do
              expect(mailer_class).to receive(mailer_method).once.and_return(mailer_msg)
              subject
            end
          end

          context 'mailer_method set via builder' do
            let!(:builder) { HeyYou::Builder.new('rspec.test_notification_with_mailer_method', pass_variable: FFaker::Lorem.word) }

            it 'call mailer_class mailer_method' do
              expect(mailer_class).to receive(mailer_method).once.and_return(mailer_msg)
              subject
            end
          end

          context 'mailer_method set via option' do
            subject { described_class.send!(builder, to: user_email, mailer_class: mailer_class, mailer_method: mailer_method) }

            it 'call mailer_class mailer_method' do
              expect(mailer_class).to receive(mailer_method).once.and_return(mailer_msg)
              subject
            end
          end

          context 'mailer_method not set' do
            let!(:builder) { HeyYou::Builder.new('rspec.test_notification', pass_variable: FFaker::Lorem.word) }
            before do
              HeyYou::Config::Email.instance.instance_variable_set(
                :@default_mailer_method, HeyYou::Config::Email::DEFAULT_ACTION_MAILER_METHOD
              )
            end

            it 'call mailer_class#send!' do
              expect(mailer_class).to receive(:send!).once.and_return(mailer_msg)
              subject
            end
          end
        end
      end

      context 'mail_class was not set' do
        it 'raise error MailerClassNotDefined' do
          expect { subject }.to raise_error(described_class::MailerClassNotDefined)
        end
      end
    end

    context 'default mailer' do
      context 'all credentials presents' do
        before do
          HeyYou::Config.instance.email.from = from
          HeyYou::Config.instance.email.delivery_method = :test
          HeyYou::Config::Email.instance.instance_variable_set(:@default_mailing, true)
        end

        it 'send email' do
          expect { subject }.to change(Mail::TestMailer.deliveries, :length).by(1)
          msg = Mail::TestMailer.deliveries.last
          expect(msg.from.first).to eq(from)
          expect(msg.to.first).to eq(user_email)
          expect(msg.subject).to match(/Test/)
          expect(msg.body.to_s).to match(/Test/)
        end
      end

      context 'not all credentials presents' do
        before do
          HeyYou::Config.instance.email.from = nil
        end

        it 'raise error' do
          expect { subject }.to raise_error(described_class::CredentialsNotExists)
        end
      end
    end
  end
end