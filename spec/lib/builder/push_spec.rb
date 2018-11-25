require 'spec_helper'

RSpec.describe HeyYou::Builder::Push do
  include_examples :have_readers, :body, :title, :data
end