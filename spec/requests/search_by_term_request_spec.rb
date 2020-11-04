# frozen_string_literal: true

RSpec.describe Admin::AuthorsController do
  before do
    ActiveAdmin.register Author do; active_admin_search! end
    Rails.application.reload_routes!
  end
  let(:term) { nil }
  subject { get "/admin/authors/search?term=#{term || ''}" }
  let(:actual_name) { 'RSpec' }
  let(:actual_last_name) { 'framework' }
  let!(:record) { FactoryBot.create(:author, name: actual_name, last_name: actual_last_name) }
  let!(:record_another) { FactoryBot.create(:author, name: 'RSpAnotherName', last_name: 'framework') }

  context 'search with empty term' do
    let(:term) { nil }

    it 'should find all records' do
      subject
      expect(request.params).to match hash_including term: '', action: 'search'
      expect(response_json.size).to eq Author.all.count
    end
  end

  context 'search by entire exact text' do
    let(:term) { actual_name }

    it 'should find record' do
      subject
      expect(request.params).to match hash_including term: 'RSpec', action: 'search'
      expect(response_json.size).to eq 1
      expect(response_json).to match_array hash_including(value: record.id, text: record.display_name)
    end
  end

  context 'search by partial name' do
    let(:term) { 'RS' }

    it 'should find al records that contains "RS" name' do
      subject
      expect(request.params).to match hash_including term: 'RS', action: 'search'
      expect(response_json.size).to eq 2
    end
  end

  context 'search by partial name' do
    let(:term) { 'RSp' }

    it 'should find all records that contains "RSp" name' do
      subject
      expect(request.params).to match hash_including term: 'RSp', action: 'search'
      expect(response_json.size).to eq 2
    end
  end

  context 'search by partial name' do
    let(:term) { 'RSpe' }

    it 'should find only one record that contains "RSpe" name' do
      subject
      expect(request.params).to match hash_including term: 'RSpe', action: 'search'
      expect(response_json.size).to eq 1
      expect(response_json).to match_array hash_including(value: record.id, text: record.display_name)
    end
  end

  context 'search by term scope but model not have that scope' do
    before do
      ActiveAdmin.register ModelWithoutTermScope do; active_admin_search! end
      Rails.application.reload_routes!
    end

    subject { get "/admin/model_without_term_scopes/search?term=#{term}" }
    let(:term) { 'RSpec' }

    it 'should have empty array' do
      subject
      expect(response_json).to eq []
    end
  end

  context 'when change default json_term_key to term2' do
    # scope named term2 defined in Author model performs search by name_equals strategy
    before do
      ActiveAdmin.register ModelWithoutTermScope do; active_admin_search! json_term_key: :term2 end
      Rails.application.reload_routes!
    end

    let(:term) { 'RSpec' }
    subject { get "/admin/authors/search?term2=#{term}" }

    it 'should have empty array' do
      subject
      expect(request.params).to match hash_including term2: 'RSpec', action: 'search'
      expect(response_json.size).to eq 1
      expect(response_json).to match_array hash_including(value: record.id, text: record.display_name)
    end
  end
end
