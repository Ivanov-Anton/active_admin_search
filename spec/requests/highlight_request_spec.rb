# frozen_string_literal: true

RSpec.describe 'DSL option :highlight' do
  let(:term_value) { nil }
  subject { get "/admin/authors/search?term=#{term_value}" }
  let!(:record) { FactoryBot.create(:author, name: 'Author') }
  before do
    ActiveAdmin.register Author do; active_admin_search! highlight: :term  end
    Rails.application.reload_routes!
  end

  describe 'when highlight whole search term' do
    let(:term_value) { record.name }

    it 'should highlight responce' do
      subject
      expect(response_json.size).to eq 1
      expect(response_json).to match_array hash_including(
         value: record.id,
         text: "#{record.id} <mark>Author</mark>"
      )
    end
  end

  describe 'when highlight whole search term' do
    let(:term_value) { record.name.last(4) }

    it 'should highlight responce' do
      subject
      expect(response_json.size).to eq 1
      expect(response_json).to match_array hash_including(
         value: record.id,
         text: "#{record.id} Au<mark>thor</mark>"
      )
    end
  end
end