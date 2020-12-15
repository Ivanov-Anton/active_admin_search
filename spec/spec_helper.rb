# frozen_string_literal: true

require 'bundler'

ENV['RAILS_ENV'] = 'test'
if ENV['CI']
  require 'coveralls'
  Coveralls.wear!
end
require 'rails'
ENV['RAILS'] = Rails.version # 6.0.3.4 by default

ENV['RAILS_ROOT'] = File.expand_path("../rails/rails-#{ENV['RAILS']}", __FILE__)

system 'rake setup' unless File.exist?(ENV['RAILS_ROOT'])

require 'rails/all'
require 'active_admin'
require 'active_admin_search'
require 'factory_bot_rails'

# TODO use dynamic method to require all support files
require 'support/response_json_rspec_helpers'
require 'support/ext/tag_model_ext'
require 'support/ext/author_model_ext'
require 'support/ext/article_model_ext'

ActiveAdmin.application.load_paths = [ENV['RAILS_ROOT'] + '/app/admin']

require "rails/rails-#{ENV['RAILS']}/config/environment"

# Add extentions module for models
Author.include AuthorModelExt
Article.include ArticleModelExt
Tag.include TagModelExt

ActiveAdmin.application.authentication_method = false
ActiveAdmin.application.current_user_method = false
ActiveAdmin::ResourceDSL.include ActiveAdminSearch

require 'rspec/rails'

FactoryBot.definition_file_paths << File.expand_path('factories', __dir__)
FactoryBot.find_definitions

Ransack.configure do |config|
  # Accept my custom scope values as what they are
  config.sanitize_custom_scope_booleans = true
end

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = true

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
end
