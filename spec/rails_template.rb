# frozen_string_literal: true

# This gem is unnecessary on Unix-based systems in general
gsub_file "Gemfile", /gem 'tzinfo-data.*/, 'gem "draper"'

generate :model, 'Author name:string last_name:string deleted_at:date type_id:integer timestamps'
generate :model, 'Article title:string body:text author_id:integer published:boolean visible:boolean'
generate :model, 'Tag name:string visible:boolean article_id:integer'
generate :model, 'ModelWithoutTermScope name:string text:string body:string'

remove_dir 'spec'

# initializers ransack files
create_file 'config/initializers/ransack.rb' do <<-RUBY
  # frozen_string_literal: true
  Ransack.configure do |config|
  # Accept my custom scope values as what they are
  config.sanitize_custom_scope_booleans = false
end
RUBY
end

# Add our local Active Admin to the load path
insert_into_file 'config/environment.rb', after: "require_relative 'application'" do <<-RUBY

$LOAD_PATH.unshift("#{File.expand_path(File.join(File.dirname(__FILE__),'..', 'lib'))}")
require 'active_admin'
RUBY
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

generate :'active_admin:install --skip-users'
generate :'formtastic:install'
generate :'draper:install'
generate :'decorator Author'

remove_dir 'spec'

create_file 'app/admin/authors.rb' do <<-RUBY
  ActiveAdmin.register Author do
    decorate_with AuthorDecorator
    active_admin_search!
  end
RUBY
end

insert_into_file 'app/decorators/application_decorator.rb', after: "ApplicationDecorator < Draper::Decorator\n" do <<-RUBY
  def show_decorated_id
    'decorated id'
  end

RUBY
end

route "root :to => 'admin/dashboard#index'"

rake 'db:migrate'

gsub_file "config/boot.rb", /^.*BUNDLE_GEMFILE.*$/, <<-RUBY
  ENV['BUNDLE_GEMFILE'] = "#{File.expand_path(ENV['BUNDLE_GEMFILE'])}"
RUBY

def generate_bundler_binstub
  # disable default behaviour
end
