# frozen_string_literal: true

RSpec.describe 'Test decorator', type: :request do
  subject { get '/admin/decorators/search?term=A' }

  let!(:record) { FactoryBot.create(:author, :personal) }
  let!(:other_record) { FactoryBot.create(:author, :business) }

  describe 'when defined method: decorate_with' do
    let(:hash_for_record) do
      {
        show_decorated_id: record.decorate.show_decorated_id,
        text: record.display_name,
        value: record.id
      }
    end
    let(:hash_for_other_record) do
      {
        show_decorated_id: other_record.decorate.show_decorated_id,
        text: other_record.display_name,
        value: other_record.id
      }
    end

    before do
      ActiveAdmin.register Author, as: 'decorator' do
        decorate_with AuthorDecorator
        active_admin_search! additional_payload: :show_decorated_id
      end
      Rails.application.reload_routes!
    end

    it 'has correct record count' do
      subject
      expect(response_json.size).to eq 2
    end

    it 'has decorated method' do
      subject
      expect(response_json).to match_array [hash_including(hash_for_record), hash_including(hash_for_other_record)]
    end
  end
end
