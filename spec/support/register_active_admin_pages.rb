# frozen_string_literal: true

ActiveAdmin.register Post, as: 'Post' do
  active_admin_search!
end

ActiveAdmin.register Author, as: 'Author' do
  active_admin_search!
end

Rails.application.reload_routes!