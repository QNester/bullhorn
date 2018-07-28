require 'spec_helper'

RSpec.describe Horn::Builder::Email do
  include_examples :have_readers, :subject, :body, :layout
end