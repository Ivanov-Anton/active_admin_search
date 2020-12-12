# frozen_string_literal: true

RSpec.describe Admin::AuthorsController do
  subject { get "/admin/authors/search?term=Author" }
  let!(:record) { FactoryBot.create(:author) }
  let!(:article) { FactoryBot.create(:article, author: record) }
  let!(:tag_red) { FactoryBot.create(:tag, article: article, name: 'red') }
  let!(:tag_green) { FactoryBot.create(:tag, article: article, name: 'green') }

  let!(:second_record) { FactoryBot.create(:author) }
  let!(:second_article) { FactoryBot.create(:article, author: second_record) }
  let!(:second_tag_red) { FactoryBot.create(:tag, article: second_article, name: 'red') }
  let!(:second_tag_green) { FactoryBot.create(:tag, article: second_article, name: 'green') }

  describe 'default behavior' do
    before do
      ActiveAdmin.register Author do; active_admin_search! display_method: :display_any_tag_name end
      Rails.application.reload_routes!
    end

    it 'should have record' do
      expect { subject }.to make_database_queries(count: 5)
      # 1 query to get authors
      # 2 query to get 2 articles
      # and finally 2 query to get 2 red tags
      expect(response_json.size).to eq 2
    end
  end

  describe 'with includes settings' do
    before do
      ActiveAdmin.register Author do; active_admin_search! display_method: :display_any_tag_name, includes: [articles: :tags] end
      Rails.application.reload_routes!
    end

    it 'should perform less queries' do
      expect { subject }.to make_database_queries(count: 3)
      expect(response_json.size).to eq 2
    end
  end
end