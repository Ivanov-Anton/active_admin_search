# frozen_string_literal: true

# This gem is unnecessary on Unix-based systems in general
gsub_file "Gemfile", /gem 'tzinfo-data.*/, 'gem "draper"'

generate :model, 'Author name:string last_name:string deleted_at:date type_id:integer timestamps'
generate :model, 'Article title:string body:text author_id:integer published:boolean visible:boolean'
generate :model, 'Tag name:string visible:boolean article_id:integer'
generate :model, 'ModelWithoutTermScope name:string text:string body:string'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

generate :'active_admin:install --skip-users'
rake 'db:migrate'
# generate :'active_admin:resource Author'
generate :'formtastic:install'
generate :'draper:install'
generate :'decorator Author'

remove_dir 'spec'

insert_into_file 'app/decorators/application_decorator.rb', after: "ApplicationDecorator < Draper::Decorator\n" do <<-RUBY
  def show_decorated_id
    'decorated id'
  end

RUBY
end

route "root :to => 'admin/dashboard#index'"

def generate_bundler_binstub
  # disable default behaviour
end
