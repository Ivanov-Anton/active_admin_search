# frozen_string_literal: true

RSpec.describe 'Search by prefix id:', type: :request do
  subject { get "/admin/prefixes/search?term=#{term_value}" }

  let(:term_value) { nil }
  let!(:record) { FactoryBot.create(:author) }

  before { FactoryBot.create_list(:author, 10) }

  describe 'when search by id prefix' do
    let(:term_value) { "id:#{record.id}" }

    before do
      ActiveAdmin.register Author, as: 'prefix' do
        active_admin_search!
      end
      Rails.application.reload_routes!
    end

    it 'has correct record count' do
      subject
      expect(response_json.size).to eq 1
    end

    it 'has record attributes' do
      subject
      expect(response_json).to match_array hash_including(value: record.id, text: record.display_name)
    end
  end
end
