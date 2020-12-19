# frozen_string_literal: true

RSpec.describe 'DSL option :display_method', type: :request do
  subject { get "/admin/display_methods/search?term=#{term}" }

  let(:term) { 'RSpec' }
  let(:actual_name) { 'RSpec' }
  let(:actual_last_name) { 'framework' }
  let!(:record) { FactoryBot.create(:author, name: actual_name, last_name: actual_last_name) }

  context 'when search by default display_method' do
    before do
      ActiveAdmin.register Author, as: 'display_method' do
        active_admin_search!
      end
      Rails.application.reload_routes!
    end

    it 'has correct record count' do
      subject
      expect(response_json.size).to eq 1
    end

    it 'has correct request params' do
      subject
      expect(request.params).to match hash_including term: term, action: 'search'
    end

    it 'finds record' do
      subject
      expect(response_json).to match_array hash_including(value: record.id, text: record.display_name)
    end
  end

  context 'when search by customer display_method named: display_name_ajax' do
    before do
      ActiveAdmin.register Author, as: 'display_method' do
        active_admin_search! display_method: :display_name_ajax
      end
      Rails.application.reload_routes!
    end

    it 'has correct record count' do
      subject
      expect(response_json.size).to eq 1
    end

    it 'has correct request params' do
      subject
      expect(request.params).to match hash_including term: term, action: 'search'
    end

    it 'has find record' do
      subject
      expect(response_json).to match_array hash_including(value: record.id, text: record.display_name_ajax)
    end
  end

  # TODO: need to implement raise if not have defined display_method in model
  xcontext 'search by unknown display_method' do
    before do
      ActiveAdmin.register Author, as: 'display_method' do
        active_admin_search! display_method: :display_name_unknown
      end
      Rails.application.reload_routes!
    end

    xit 'should raise error' do
      expect(subject).to raise_exception NoMethodError
      # expect(request.params).to match hash_including term: '', action: 'search'
      # expect(response_json.size).to eq 1
      # expect(response_json).to match_array hash_including(value: record.id, text: record.display_name_ajax)
    end
  end
end
