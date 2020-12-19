# frozen_string_literal: true

RSpec.describe 'DSL option :includes', type: :request do
  subject { get '/admin/includes/search?term=Author' }

  before do
    record = FactoryBot.create(:author)
    article = FactoryBot.create(:article, author: record)
    FactoryBot.create(:tag, article: article, name: 'red')
    FactoryBot.create(:tag, article: article, name: 'green')
    second_record = FactoryBot.create(:author)
    second_article = FactoryBot.create(:article, author: second_record)
    FactoryBot.create(:tag, article: second_article, name: 'red')
    FactoryBot.create(:tag, article: second_article, name: 'green')
  end

  describe 'with default behavior' do
    before do
      ActiveAdmin.register Author, as: 'include' do
        active_admin_search! display_method: :display_any_tag_name
      end
      Rails.application.reload_routes!
    end

    # 1 query to get authors
    # 2 query to get 2 articles = 3
    # and finally 2 query to get 2 red tags = 5
    it { expect { subject }.to make_database_queries(count: 5) }

    it 'has correct count record' do
      subject
      expect(response_json.size).to eq 2
    end
  end

  describe 'with includes settings' do
    before do
      ActiveAdmin.register Author, as: 'include' do
        active_admin_search! display_method: :display_any_tag_name, includes: [articles: :tags]
      end
      Rails.application.reload_routes!
    end

    it { expect { subject }.to make_database_queries(count: 3) }

    it 'has correct record count in response' do
      subject
      expect(response_json.size).to eq 2
    end
  end
end
