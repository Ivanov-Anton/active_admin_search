# frozen_string_literal: true

RSpec.describe Admin::AuthorsController do
  subject { get "/admin/authors/search?term=RSpec" }
  let!(:record) { FactoryBot.create(:author, name: 'RSpec') }

  describe 'default behavior' do
    before do
      ActiveAdmin.register Author do; active_admin_search! end
      Rails.application.reload_routes!
    end

    it 'should have record' do
      subject
      expect(response_json.size).to eq 1
    end
  end

  describe 'using term_key_rename setting' do
    before do
      ActiveAdmin.register Author do; active_admin_search! term_key_rename: :term2 end
      Rails.application.reload_routes!
    end

    it 'should have record' do
      subject
      expect(response_json.size).to eq 1
    end
  end
end