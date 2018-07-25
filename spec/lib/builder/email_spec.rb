require 'spec_helper'

RSpec.describe Bullhorn::Builder::Email do
  include_examples :have_readers, :subject, :body, :layout
end