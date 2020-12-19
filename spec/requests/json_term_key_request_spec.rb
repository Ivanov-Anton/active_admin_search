# frozen_string_literal: true

RSpec.describe 'DSL option :json_term_key', type: :request do
  subject { get "/admin/json_term_keys/search?#{json_term_key}=#{term_value}" }

  let(:json_term_key) { :term }
  let(:term_value) { nil }

  before { FactoryBot.create(:author, name: term_value) }

  context 'when default behavior' do
    before do
      ActiveAdmin.register Author, as: 'json_term_key' do
        active_admin_search!
      end
      Rails.application.reload_routes!
    end

    let(:term_value) { 'default value' }

    it 'json_term_key should be :term' do
      subject
      expect(request.params).to match hash_including term: term_value, action: 'search'
    end

    it 'has correct record count' do
      subject
      expect(response_json.size).to eq 1
    end
  end

  context 'when DSL option json_term_key: :name' do
    let(:term_value) { 'default value' }
    let(:json_term_key) { :name }

    before do
      ActiveAdmin.register Author, as: 'json_term_key' do
        active_admin_search! json_term_key: :name
      end
      Rails.application.reload_routes!
    end

    it 'json_term_key should be :name' do
      subject
      expect(request.params).to match hash_including name: term_value, action: 'search'
    end

    it 'has correct record count' do
      subject
      expect(response_json.size).to eq 1
    end
  end

  context 'when DSL option json_term_key: :another' do
    let(:term_value) { 'default value' }
    let(:json_term_key) { :another }

    before do
      ActiveAdmin.register Author, as: 'json_term_key' do
        active_admin_search! json_term_key: :another
      end
      Rails.application.reload_routes!
    end

    it 'json_term_key should be :another' do
      subject
      expect(request.params).to match hash_including another: term_value, action: 'search'
    end

    it 'has correct record count' do
      subject
      expect(response_json.size).to eq 1
    end
  end
end
