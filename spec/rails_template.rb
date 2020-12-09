# frozen_string_literal: true

# This gem is unnecessary on Unix-based systems in general
gsub_file "Gemfile", /gem 'tzinfo-data.*/, ''

generate :model, 'Author name:string last_name:string deleted_at:date type_id:integer timestamps'
generate :model, 'Article title:string body:text author_id:integer published:boolean visible:boolean'
generate :model, 'Tag name:string visible:boolean article_id:integer'
generate :model, 'ModelWithoutTermScope name:string text:string body:string'

# Filling model files
insert_into_file 'app/models/author.rb', after: "class Author < ApplicationRecord\n" do <<-RUBY
  has_many :articles

  module CONST
    AUTHOR_TYPE_ID_PERSONAL = 1
    AUTHOR_TYPE_ID_BUSINESS = 2

    AUTHOR_TYPE_IDS = {
        AUTHOR_TYPE_ID_BUSINESS => 'Business',
        AUTHOR_TYPE_ID_PERSONAL => 'Personal'
    }.freeze
  end

  validates :name, presence: true, uniqueness: true
  with_options(on: :create) do
    validates :type_id, inclusion: { in: CONST::AUTHOR_TYPE_IDS.keys }, allow_nil: true
  end

  def display_name
    id.to_s + ' ' + name.to_s
  end

  def display_name_ajax
    id.to_s + ' ' + name.to_s + '_ajax'
  end

  def display_ajax
    id.to_s + ' ' + name.to_s + 'DELETED'
  end

  def display_any_tag_name
    articles.take.tags.take.name.to_s
  end

  scope :personal, -> { where(type_id: CONST::AUTHOR_TYPE_ID_PERSONAL) }
  scope :business, -> { where(type_id: CONST::AUTHOR_TYPE_ID_BUSINESS) }
  scope :deleted, -> { where.not(deleted_at: nil) }
  scope :not_delete, -> { where(deleted_at: nil) }

  scope :term, -> (value) do
    ransack(name_contains: value).result
  end

  scope :term2, -> (value) do
    ransack(name_contains: value).result
  end

  def self.ransackable_scopes(_auth = nil)
    %w[term term2]
  end
RUBY
end
insert_into_file 'app/models/article.rb', after: "class Article < ApplicationRecord\n" do <<-RUBY
  belongs_to :author
  validates :title, presence: true
  has_many :tags, class_name: 'Tag'

  def display_name
    id.to_s + ' ' + title.to_s
  end

  scope :published, -> { where(published: true) }
  scope :visible, -> { where(visible: true) }
RUBY
end
insert_into_file 'app/models/tag.rb', after: "class Tag < ApplicationRecord\n" do <<-RUBY
  belongs_to :article, class_name: 'Article'

  def display_name
    id.to_s + ' ' + name.to_s
  end

  scope :visible, -> { where(visible: true) }
RUBY
end

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

create_file 'app/admin/authors.rb' do <<-RUBY
  ActiveAdmin.register Author do
    active_admin_search!
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
