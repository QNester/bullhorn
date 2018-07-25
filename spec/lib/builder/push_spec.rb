require 'spec_helper'

RSpec.describe Bullhorn::Builder::Push do
  include_examples :have_readers, :body, :title, :data
end