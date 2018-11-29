require 'spec_helper'

RSpec.describe HeyYou::Config::Email do
  include_examples :singleton

  describe 'attributes' do
    include_examples :have_accessors, :from, :default_email, :async
  end
end