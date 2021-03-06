# frozen_string_literal: true

RSpec.describe 'Search by prefix id:' do
  let(:term_value) { nil }
  subject { get "/admin/prefixes/search?term=#{term_value}" }
  let!(:records) { FactoryBot.create_list(:author, 10) }
  let!(:record) { FactoryBot.create(:author) }

  describe 'search by id' do
    let(:term_value) { "id:#{record.id}" }
    before do
      ActiveAdmin.register Author, as: 'prefix' do; active_admin_search! end
      Rails.application.reload_routes!
    end

    it 'should have record' do
      subject
      expect(response_json.size).to eq 1
      expect(response_json).to match_array hash_including(value: record.id, text: record.display_name)
    end
  end
end
