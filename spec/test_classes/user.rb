require_relative 'push_token'
require_relative '../../lib/bullhorn'

class User
  extend Bullhorn::Receiver

  receive(
    sms: -> { number },
    push: -> { push_token.value },
    email: -> { email[:address] }
  )

  def number
    SecureRandom.uuid
  end

  def push_token
    @push_token ||= PushToken.new
  end

  def email
    {
      address: 'qnesterr@gmail.com'
    }
  end
end