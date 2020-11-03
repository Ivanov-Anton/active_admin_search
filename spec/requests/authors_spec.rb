# frozen_string_literal: true

RSpec.describe Admin::AuthorsController do
  let(:term) { nil }
  subject { get "/admin/authors/search?term=#{term || ''}" }
  let!(:record) { FactoryBot.create(:author, name: 'RSpec') }

  context 'get /admin/authors/search' do
    it 'should response empty array' do
      subject
      expect(response_json).to eq []
    end
  end

  context 'with params' do
    let(:term) { 'RSpec' }

    it 'should find record' do
      subject
      expect(response_json.size).to eq 1
      expect(response_json).to match_array hash_including(value: 1, text: '1 RSpec')
    end
  end

  context 'when use prefix "id:"' do
    let(:term) { "id:#{record.id}" }

    it 'should find record' do
      subject
      expect(response_json.size).to eq 1
      expect(response_json).to match_array hash_including(value: 1, text: '1 RSpec')
    end
  end
end
