# frozen_string_literal: true

RSpec.describe ApplicationController do
  let!(:author) { FactoryBot.create(:author) }
  let!(:target_article) { FactoryBot.create(:article, author: author) }
  let!(:target_article_second) { FactoryBot.create(:article, author: author) }
  let!(:shadow_article) { FactoryBot.create(:article) }

  describe 'default behavior' do
    subject { get "/admin/articles/search?term=&q[author_id_eq]=#{author.id}" }
    before do
      ActiveAdmin.register Article do; active_admin_search! end
      Rails.application.reload_routes!
    end

    it 'should have record' do
      subject
      expect(response_json.size).to eq 2
    end
  end
end