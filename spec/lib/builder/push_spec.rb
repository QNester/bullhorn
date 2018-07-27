require 'spec_helper'

RSpec.describe Horn::Builder::Push do
  include_examples :have_readers, :body, :title, :data
end