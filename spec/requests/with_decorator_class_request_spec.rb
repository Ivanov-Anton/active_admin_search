# frozen_string_literal: true

RSpec.describe Admin::AuthorsController do
  subject { get "/admin/authors/search?term=" }
  let!(:record) { FactoryBot.create(:author, :personal) }
  let!(:other_record) { FactoryBot.create(:author, :business) }

  describe 'when defined method: decorate_with' do
    before do
      ActiveAdmin.register Author do
        decorate_with AuthorDecorator
        active_admin_search! additional_payload: :show_decorated_id
      end
      Rails.application.reload_routes!
    end

    it 'should have decorated method' do
      subject
      expect(response_json.size).to eq 2
      expect(response_json).to match_array [
        hash_including(show_decorated_id: record.decorate.show_decorated_id, text: record.display_name, value: record.id),
        hash_including(show_decorated_id: other_record.decorate.show_decorated_id, text: other_record.display_name, value: other_record.id)
      ]
    end
  end
end
