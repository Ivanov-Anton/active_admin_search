# frozen_string_literal: true

RSpec.describe 'Detailed search by term', type: :request do
  subject { get "/admin/terms/search?term=#{term}" }

  before do
    ActiveAdmin.register Author, as: 'term' do
      active_admin_search!
    end
    Rails.application.reload_routes!
    FactoryBot.create(:author, name: 'RSpAnotherName', last_name: 'framework')
  end

  let(:term) { nil }
  let(:actual_name) { 'RSpec' }
  let(:actual_last_name) { 'framework' }
  let!(:record) { FactoryBot.create(:author, name: actual_name, last_name: actual_last_name) }

  context 'when search with empty term' do
    let(:term) { 'RSp' }

    it 'has correct request params' do
      subject
      expect(request.params).to match hash_including term: term, action: 'search'
    end

    it 'finds all records' do
      subject
      expect(response_json.size).to eq Author.all.count
    end
  end

  context 'when search by entire exact text' do
    let(:term) { actual_name }

    it 'has correct record count' do
      subject
      expect(response_json.size).to eq 1
    end

    it 'has correct request params' do
      subject
      expect(request.params).to match hash_including term: 'RSpec', action: 'search'
    end

    it 'has correct attributes record of response' do
      subject
      expect(response_json).to match_array hash_including(value: record.id, text: record.display_name)
    end
  end

  context 'when search by partial (first 2 letter) name' do
    let(:term) { 'RS' }

    it 'has correct record count' do
      subject
      expect(response_json.size).to eq 2
    end

    it 'finds all records that contains "RS" name' do
      subject
      expect(request.params).to match hash_including term: 'RS', action: 'search'
    end
  end

  context 'when search by partial (first 3 letter) name' do
    let(:term) { 'RSp' }

    it 'has correct record count' do
      subject
      expect(response_json.size).to eq 2
    end

    it 'finds all records that contains "RSp" name' do
      subject
      expect(request.params).to match hash_including term: 'RSp', action: 'search'
    end
  end

  context 'when search by partial (first 4 letter) name' do
    let(:term) { 'RSpe' }

    it 'has correct record count' do
      subject
      expect(response_json.size).to eq 1
    end

    it 'has correct request params' do
      subject
      expect(request.params).to match hash_including term: 'RSpe', action: 'search'
    end

    it 'finds only one record that contains "RSpe" name' do
      subject
      expect(response_json).to match_array hash_including(value: record.id, text: record.display_name)
    end
  end

  context 'when search by term scope but model not have that scope' do
    subject { get "/admin/terms/search?term=#{term}" }

    before do
      ActiveAdmin.register ModelWithoutTermScope, as: 'terms' do
        active_admin_search!
      end
      Rails.application.reload_routes!
    end

    let(:term) { 'RSpec' }

    it 'has empty array' do
      subject
      expect(response_json).to eq []
    end
  end

  context 'when change default json_term_key to term2' do
    # scope named term2 defined in Author model performs search by name_equals strategy
    subject { get "/admin/terms/search?term2=#{term}" }

    before do
      ActiveAdmin.register Author, as: 'term' do
        active_admin_search! json_term_key: :term2
      end
      Rails.application.reload_routes!
    end

    let(:term) { 'RSpec' }

    it 'has correct record count' do
      subject
      expect(response_json.size).to eq 1
    end

    it 'has correct request params' do
      subject
      expect(request.params).to match hash_including term2: 'RSpec', action: 'search'
    end

    it 'has correct attributes record of response' do
      subject
      expect(response_json).to match_array hash_including(value: record.id, text: record.display_name)
    end
  end
end
