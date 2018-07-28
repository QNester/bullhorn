require_relative 'push_token'

class User
  extend Horn::Receiver
  #
  # receive(
  #   sms: -> { number },
  #   push: -> { push_token.value },
  #   email: -> { email[:address] }
  # )

  def number
    FFaker
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