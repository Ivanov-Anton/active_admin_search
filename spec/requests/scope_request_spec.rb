# frozen_string_literal: true

RSpec.describe 'DSL option :default_scope and request option :skip_default_scopes', type: :request do
  subject { get '/admin/default_scopes/search?term=A' }

  let!(:record) { FactoryBot.create(:author, :personal) }

  before { FactoryBot.create(:author, :business) }

  describe 'setting named: default_scope' do
    context 'when defined default_scope: :personal' do
      before do
        ActiveAdmin.register Author, as: 'default_scope' do
          active_admin_search! default_scope: :personal
        end
        Rails.application.reload_routes!
      end

      it 'has correct record count' do
        subject
        expect(response_json.size).to eq 1
      end

      it 'has record' do
        subject
        expect(response_json).to match_array hash_including(value: record.id, text: record.display_name)
      end
    end

    context 'when defined default_scope: :personal and override then throught url' do
      subject { get '/admin/default_scopes/search?term=A&skip_default_scopes=true' }

      before do
        ActiveAdmin.register Author, as: 'default_scope' do
          active_admin_search! default_scope: :personal
        end
        Rails.application.reload_routes!
      end

      it 'has all records' do
        subject
        expect(response_json.size).to eq 2
      end
    end

    context 'when defined default_scope as array' do
      subject { get '/admin/default_scopes/search?term=A' }

      before do
        ActiveAdmin.register Author, as: 'default_scope' do
          active_admin_search! default_scope: %i[personal not_delete]
        end
        Rails.application.reload_routes!
        FactoryBot.create(:author, :personal, :deleted)
      end

      it 'has all records' do
        subject
        expect(response_json.size).to eq 1
      end
    end
  end

  describe 'url setting named: scope' do
    context 'when pass scope: personal' do
      subject { get '/admin/default_scopes/search?term=A&scope=personal' }

      before do
        ActiveAdmin.register Author, as: 'default_scope' do
          active_admin_search!
        end
        Rails.application.reload_routes!
      end

      it 'has correct request' do
        subject
        expect(response_json).to match_array hash_including(value: record.id, text: record.display_name)
      end

      it 'has correct record count' do
        subject
        expect(response_json.size).to eq 1
      end

      it 'has scoped record only' do
        subject
        expect(response_json.first.fetch(:value)).to eq record.id
      end
    end

    context 'when pass couple scopes separated coma' do
      subject { get '/admin/default_scopes/search?term=A&scope=personal,not_delete' }

      before do
        ActiveAdmin.register Author, as: 'default_scope' do
          active_admin_search!
        end
        Rails.application.reload_routes!
        FactoryBot.create(:author, :personal, :deleted)
      end

      it 'has one record only' do
        subject
        expect(response_json.size).to eq 1
      end

      it 'has correct attributes in response' do
        subject
        expect(response_json).to match_array hash_including(
          value: record.id,
          text: record.display_name
        )
      end

      it 'has correct request params' do
        subject
        expect(response_json).to match_array hash_including(value: record.id, text: record.display_name)
      end
    end
  end
end
