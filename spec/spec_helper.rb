require "bundler/setup"
require 'webmock'
require "bullhorn"
require 'pry-byebug'

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f }

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
    Bullhorn::Config.instance.instance_variable_set(:@configured, false)
    Bullhorn::Config.instance_variable_set(:@configured, false)
    Bullhorn::Config.instance.instance_variable_set(:@collection, nil)
    Bullhorn::Config.instance.instance_variable_set(:@env_collection, nil)
  end
end
