# frozen_string_literal: true

RSpec.describe ApplicationController do
  subject { get "/admin/authors/search?term=#{term_value}" }
  let!(:records) { FactoryBot.create_list(:author, 10) }
  let!(:record) { FactoryBot.create(:author) }

  describe 'search by id' do
    let(:term_value) { "id:#{record.id}" }
    before do
      ActiveAdmin.register Author do; active_admin_search! end
      Rails.application.reload_routes!
    end

    it 'should have record' do
      subject
      expect(response_json.size).to eq 1
      expect(response_json).to match_array hash_including(value: record.id, text: record.display_name)
    end
  end
end
