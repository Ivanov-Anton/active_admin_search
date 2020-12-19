# frozen_string_literal: true

RSpec.describe 'Dependent search', type: :request do
  let!(:author) { FactoryBot.create(:author) }

  before do
    FactoryBot.create(:article, author: author)
    FactoryBot.create(:article, author: author)
    FactoryBot.create(:article)
  end

  describe 'when default behavior' do
    subject { get "/admin/dependents/search?term=&q[author_id_eq]=#{author.id}" }

    before do
      ActiveAdmin.register Article, as: 'Dependent' do
        active_admin_search!
      end
      Rails.application.reload_routes!
    end

    it 'has record' do
      subject
      expect(response_json.size).to eq 2
    end
  end
end
