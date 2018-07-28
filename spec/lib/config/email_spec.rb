require 'spec_helper'

RSpec.describe Horn::Config::Email do
  include_examples :singleton

  describe 'attributes' do
    include_examples :have_accessors, :layout, :from
  end
end