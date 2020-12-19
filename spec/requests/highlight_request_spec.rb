# frozen_string_literal: true

RSpec.describe 'DSL option :highlight', type: :request do
  subject { get "/admin/highlights/search?term=#{term_value}" }

  let(:term_value) { nil }
  let!(:record) { FactoryBot.create(:author, name: 'Author') }

  before do
    ActiveAdmin.register Author, as: 'highlight' do
      active_admin_search! highlight: :term
    end
    Rails.application.reload_routes!
  end

  describe 'when highlight whole search term' do
    let(:term_value) { record.name }

    it 'has correct record count' do
      subject
      expect(response_json.size).to eq 1
    end

    it 'has highlights all responce' do
      subject
      expect(response_json).to match_array hash_including(
        value: record.id,
        text: "#{record.id} <mark>Author</mark>"
      )
    end
  end

  describe 'when equal only last 4 letters of search term' do
    let(:term_value) { record.name.last(4) }

    it 'has correct record count' do
      subject
      expect(response_json.size).to eq 1
    end

    it 'has highlights last 4 letters' do
      subject
      expect(response_json).to match_array hash_including(
        value: record.id,
        text: "#{record.id} Au<mark>thor</mark>"
      )
    end
  end
end
