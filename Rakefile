# frozen_string_literal: true

require 'byebug'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rails/version'

RSpec::Core::RakeTask.new(:spec)
Bundler::GemHelper.install_tasks

require 'rubocop/rake_task'

RuboCop::RakeTask.new

task default: %i[spec]

task :clean do
  system('rm -rf spec/rails')
end

task :setup do
  system('mkdir spec/rails') unless File.exist?('spec/rails')
  rails_new_opts = %w[
    --skip-turbolinks
    --skip-spring
    --skip-bootsnap
    --skip-webpack-install
    --skip-git
    --skip-test
    --skip-system-test
    --skip-keeps
    --skip-javascript
    --skip-test-unit
    --template=spec/rails_template.rb
  ]

  system "bundle exec rails new spec/rails/rails-#{Rails::VERSION::STRING} #{rails_new_opts.join(' ')}"
end
