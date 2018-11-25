require 'spec_helper'

RSpec.describe HeyYou::Config::Email do
  include_examples :singleton

  describe 'attributes' do
    include_examples :have_accessors, :layout, :from
  end
end