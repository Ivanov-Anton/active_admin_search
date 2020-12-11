# frozen_string_literal: true

RSpec.describe Admin::AuthorsController do
  let!(:record) { FactoryBot.create(:author) }

  context 'default behavior' do
    subject { get "/admin/authors/search?term=Author" }
    before do
      ActiveAdmin.register Author do; active_admin_search! end
      Rails.application.reload_routes!
    end

    it 'should have default fields' do
      subject
      expect(response_json.size).to eq 1
      expect(response_json).to match_array hash_including(
         value: record.id,
         text: record.display_name,
      )
    end
  end

  context 'when default variable value which forwards id of record is changed to last_name field' do
    subject { get "/admin/authors/search?term=Author" }
    before do
      ActiveAdmin.register Author do; active_admin_search! value_method: :last_name end
      Rails.application.reload_routes!
    end

    it 'should have default fields' do
      subject
      expect(response_json.size).to eq 1
      expect(response_json).to match_array hash_including(
        value: record.last_name,
        text: record.display_name,
      )
    end
  end
end
