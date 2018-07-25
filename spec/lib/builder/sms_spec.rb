require 'spec_helper'

RSpec.describe Bullhorn::Builder::Sms do
  include_examples :have_readers, :text
end