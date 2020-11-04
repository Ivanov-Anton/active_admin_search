# frozen_string_literal: true

RSpec.describe Admin::AuthorsController do
  let(:json_term_key) { :term }
  let(:term_value) { nil }
  subject { get "/admin/authors/search?#{json_term_key}=#{term_value || ''}" }
  let!(:record) { FactoryBot.create(:author, name: term_value) }

  context 'when default behavior' do
    before do
      ActiveAdmin.register Author do; active_admin_search! end
      Rails.application.reload_routes!
    end
    let(:term_value) { 'default value' }

    it 'json_term_key should be :term' do
      subject
      expect(request.params).to match hash_including term: term_value, action: 'search'
    end

    it 'should find record' do
      subject
      expect(response_json.size).to eq 1
    end
  end

  context 'when json_term_key: :name' do
    let(:term_value) { 'default value' }
    let(:json_term_key) { :name }
    before do
      ActiveAdmin.register Author do; active_admin_search! json_term_key: :name end
      Rails.application.reload_routes!
    end

    it 'json_term_key should be :name' do
      subject
      expect(request.params).to match hash_including name: term_value, action: 'search'
    end

    it 'should find record' do
      subject
      expect(response_json.size).to eq 1
    end
  end

  # You can change json_term_key through sub_id key too.
  context 'when json_term_key: :another' do
    let(:term_value) { 'default value' }
    let(:json_term_key) { :another }
    before do
      ActiveAdmin.register Author do; active_admin_search! sub_id: :another end
      Rails.application.reload_routes!
    end

    it 'json_term_key should be :another' do
      subject
      expect(request.params).to match hash_including another: term_value, action: 'search'
    end
  end
end
