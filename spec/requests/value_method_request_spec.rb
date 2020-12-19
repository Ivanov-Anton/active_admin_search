# frozen_string_literal: true

RSpec.describe 'DSL option :value_method', type: :request do
  let!(:record) { FactoryBot.create(:author) }

  context 'when default behavior' do
    subject { get '/admin/value_methods/search?term=Author' }

    before do
      ActiveAdmin.register Author, as: 'value_method' do
        active_admin_search!
      end
      Rails.application.reload_routes!
    end

    it 'has correct record count' do
      subject
      expect(response_json.size).to eq 1
    end

    it 'has default fields in response' do
      subject
      expect(response_json).to match_array hash_including(value: record.id, text: record.display_name)
    end
  end

  context 'when default variable value which forwards id of record is changed to last_name field' do
    subject { get '/admin/value_methods/search?term=Author' }

    before do
      ActiveAdmin.register Author, as: 'value_method' do
        active_admin_search! value_method: :last_name
      end
      Rails.application.reload_routes!
    end

    it 'has correct record count' do
      subject
      expect(response_json.size).to eq 1
    end

    it 'has default fields' do
      subject
      expect(response_json).to match_array hash_including(value: record.last_name, text: record.display_name)
    end
  end
end
