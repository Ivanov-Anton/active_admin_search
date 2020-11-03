# frozen_string_literal: true

# This gem is unnecessary on Unix-based systems in general
gsub_file "Gemfile", /gem 'tzinfo-data.*/, ''

generate :migration, 'create_authors name:string last_name:string'
generate :migration, 'create_posts title:string body:text author_id:integer'

copy_file File.expand_path('../app/models/author.rb', __dir__), 'app/models/author.rb'

copy_file File.expand_path('../app/models/post.rb', __dir__), 'app/models/post.rb'

# Add our local Active Admin to the load path
insert_into_file 'config/environment.rb', after: "require_relative 'application'" do <<-RUBY

$LOAD_PATH.unshift("#{File.expand_path(File.join(File.dirname(__FILE__),'..', 'lib'))}")
require 'active_admin'
RUBY
end


$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

generate :'active_admin:install --skip-users'
generate :'formtastic:install'

route "root :to => 'admin/dashboard#index'"

rake 'db:migrate'

gsub_file "config/boot.rb", /^.*BUNDLE_GEMFILE.*$/, <<-RUBY
  ENV['BUNDLE_GEMFILE'] = "#{File.expand_path(ENV['BUNDLE_GEMFILE'])}"
RUBY

def generate_bundler_binstub
  # disable default behaviour
end
