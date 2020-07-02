require_relative 'push_token'

class User
  extend HeyYou::Receiver

  def number
    FFaker
  end

  def push_token
    @push_token ||= PushToken.new
  end

  def falsey_condition
    false
  end

  def truthy_condition
    true
  end

  def email
    {
      address: 'qnesterr@gmail.com'
    }
  end
end