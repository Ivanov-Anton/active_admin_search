# frozen_string_literal: true

RSpec.describe 'DSL option :endpoint' do
  let!(:record) { FactoryBot.create(:author) }
  before do
    ActiveAdmin.register Author do; active_admin_search!; active_admin_search! endpoint: :search_name end
    Rails.application.reload_routes!
  end

  describe 'performing by default "search" endpoint' do
    subject { get "/admin/authors/search?term=#{record.name}" }

    it 'should have record' do
      subject
      expect(response_json.size).to eq 1
    end
  end

  describe 'performing by "search_name" endpoint' do
    subject { get "/admin/authors/search_name?term=#{record.name}" }

    it 'should have record' do
      subject
      expect(response_json.size).to eq 1
    end
  end
end