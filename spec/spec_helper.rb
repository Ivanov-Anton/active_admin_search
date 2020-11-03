# frozen_string_literal: true

require 'bundler'
require 'active_admin_search'
ENV['RAILS_ENV'] = 'test'
require 'rails'
ENV['RAILS'] = Rails.version

ENV['RAILS_ROOT'] = File.expand_path("../rails/rails-#{ENV['RAILS']}", __FILE__)

system 'rake setup' unless File.exist?(ENV['RAILS_ROOT'])

require 'rails/all'
require 'active_admin'
require 'selenium-webdriver'
require 'factory_bot_rails'
require 'database_cleaner'

# TODO use dynamic method to require all support files
require 'support/capybara'
require 'support/response_json_rspec_helpers'

ActiveAdmin.application.load_paths = [ENV['RAILS_ROOT'] + '/app/admin']

require 'rails/rails-6.0.3.4/config/environment'

# require ENV['RAILS_ROOT'] + '/config/environment.rb'

ActiveAdmin.application.authentication_method = false
ActiveAdmin.application.current_user_method = false
ActiveAdmin::ResourceDSL.include ActiveAdminSearch

require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'
require 'selenium-webdriver'

FactoryBot.definition_file_paths << File.expand_path('factories', __dir__)
FactoryBot.find_definitions

require 'support/register_active_admin_pages'

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!

  config.include FactoryBot::Syntax::Methods
  config.include ResponseJsonRspecHelpers, type: :controller
  config.include ResponseJsonRspecHelpers, type: :request

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end
  config.before(:each) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.start
  end
  config.after(:each) do
    DatabaseCleaner.clean
  end
end
