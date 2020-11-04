# frozen_string_literal: true

RSpec.describe Admin::AuthorsController do
  let(:term) { nil }
  let(:record_count) { 2 }
  subject { get "/admin/authors/search?term=#{term || ''}" }
  let!(:records) { FactoryBot.create_list(:author, record_count) }

  describe 'setting named: skip_pagination' do
    context 'with limit' do
      before do
        ActiveAdmin.register Author do; active_admin_search! end
        Rails.application.reload_routes!
      end
      let(:record_count) { 501 }

      it 'should get partial records (with limit)' do
        subject
        expect(response_json.size).to eq 500
      end
    end

    context 'without limit, offset' do
      before do
        ActiveAdmin.register Author do; active_admin_search! skip_pagination: true end
        Rails.application.reload_routes!
      end
      let(:record_count) { 501 }

      it 'should get all available records' do
        subject
        expect(response_json.size).to eq 501
      end
    end

    context 'when defined specific limit: 550' do
      before do
        ActiveAdmin.register Author do; active_admin_search! limit: 550 end
        Rails.application.reload_routes!
      end
      let(:record_count) { 520 }

      it 'should get all records' do
        subject
        expect(response_json.size).to eq 520
      end
    end

    context 'when defined specific limit: 2' do
      before do
        ActiveAdmin.register Author do; active_admin_search! limit: 2 end
        Rails.application.reload_routes!
      end
      let(:record_count) { 10 }

      it 'should get partial records' do
        subject
        expect(response_json.size).to eq 2
      end
    end

    context 'when defined specific limit: 1000' do
      before do
        ActiveAdmin.register Author do; active_admin_search! limit: 1000 end
        Rails.application.reload_routes!
      end
      let(:record_count) { 500 }

      it 'should get partial records' do
        subject
        expect(response_json.size).to eq 500
      end

      # TODO fix bug
      xcontext 'per 200 pages' do
        subject { get "/admin/authors/search?term=#{term || ''}&per_page=200?page=1" }

        it 'should have 200 records' do
          subject
          expect(response_json.size).to eq 200
        end
      end
    end
  end
end
