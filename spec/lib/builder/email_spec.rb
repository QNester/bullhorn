require 'spec_helper'

RSpec.describe HeyYou::Builder::Email do
  include_examples :have_readers, :subject, :body, :layout, :mailer_class, :mailer_method
end