# frozen_string_literal: true

RSpec.describe ApplicationController do
  subject { get "/admin/authors/search?term=Author" }
  let!(:record_first) { FactoryBot.create(:author, :deleted, deleted_at: 1.hour.ago.utc) }
  let!(:record_second) { FactoryBot.create(:author, :deleted, deleted_at: 1.day.ago.utc) }
  let!(:record_last) { FactoryBot.create(:author, :deleted, deleted_at: 1.minute.ago.utc) }

  describe 'default behavior is id: :desc' do
    before do
      ActiveAdmin.register Author do; active_admin_search! end
      Rails.application.reload_routes!
    end

    it 'should have records ordered by id desc' do
      subject
      expect(response_json.size).to eq 3
      expect(response_json.first.fetch :value).to eq record_last.id
      expect(response_json.second.fetch :value).to eq record_second.id
      expect(response_json.last.fetch :value).to eq record_first.id
    end
  end

  describe 'when use setting order_clause by id asc' do
    before do
      ActiveAdmin.register Author do; active_admin_search! order_clause: :id end
      Rails.application.reload_routes!
    end

    it 'should have records ordered by id asc' do
      subject
      expect(response_json.size).to eq 3
      expect(response_json.first.fetch :value).to eq record_first.id
      expect(response_json.second.fetch :value).to eq record_second.id
      expect(response_json.last.fetch :value).to eq record_last.id
    end
  end

  describe 'when use setting order_clause by id asc' do
    before do
      ActiveAdmin.register Author do; active_admin_search! order_clause: { id: :asc } end
      Rails.application.reload_routes!
    end

    it 'should have records ordered by id asc' do
      subject
      expect(response_json.size).to eq 3
      expect(response_json.first.fetch :value).to eq record_first.id
      expect(response_json.second.fetch :value).to eq record_second.id
      expect(response_json.last.fetch :value).to eq record_last.id
    end
  end

  describe 'when use setting order_clause by deleted_at asc' do
    before do
      ActiveAdmin.register Author do; active_admin_search! order_clause: { deleted_at: :asc } end
      Rails.application.reload_routes!
    end

    it 'should have records ordered by id asc' do
      subject
      expect(response_json.size).to eq 3
      expect(response_json.first.fetch :value).to eq record_second.id # 1.day.ago.utc
      expect(response_json.second.fetch :value).to eq record_first.id # 1.hour.ago.utc
      expect(response_json.last.fetch :value).to eq record_last.id    # 1.minute.ago.utc
    end
  end

  describe 'when use setting order_clause by deleted_at desc' do
    before do
      ActiveAdmin.register Author do; active_admin_search! order_clause: { deleted_at: :desc } end
      Rails.application.reload_routes!
    end

    it 'should have records ordered by id desc' do
      subject
      expect(response_json.size).to eq 3
      expect(response_json.first.fetch :value).to eq record_first.id # 1.hour.ago.utc
      expect(response_json.second.fetch :value).to eq record_last.id # 1.minute.ago.utc
      expect(response_json.last.fetch :value).to eq record_second.id # 1.day.ago.utc
    end
  end
end
