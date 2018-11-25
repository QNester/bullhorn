require 'bundler/setup'
require 'ffaker'
require 'webmock'
require 'hey_you'
require 'byebug'

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f }

TEST_FILE = 'spec/fixtures/notifications.yml'

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  # config.filter_run :focus
  config.order = :random
  Kernel.srand config.seed

  config.before do
    HeyYou::Config.instance.instance_variable_set(:@configured, false)
    HeyYou::Config.instance_variable_set(:@configured, false)
    HeyYou::Config.instance.instance_variable_set(:@collection, nil)
    HeyYou::Config.instance.instance_variable_set(:@env_collection, nil)
  end
end
