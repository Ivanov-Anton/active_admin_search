# frozen_string_literal: true

RSpec.describe 'DSL option :default_scope and request option :skip_default_scopes' do
  subject { get "/admin/authors/search?term=A" }
  let!(:record) { FactoryBot.create(:author, :personal) }
  let!(:record_other) { FactoryBot.create(:author, :business) }

  describe 'setting named: default_scope' do
    context 'when defined default_scope: :personal' do
      before do
        ActiveAdmin.register Author do; active_admin_search! default_scope: :personal end
        Rails.application.reload_routes!
      end

      it 'should have record' do
        subject
        expect(response_json.size).to eq 1
        expect(response_json).to match_array hash_including(value: record.id, text: record.display_name)
      end
    end

    context 'when defined default_scope: :personal and override then throught url' do
      before do
        ActiveAdmin.register Author do; active_admin_search! default_scope: :personal end
        Rails.application.reload_routes!
      end
      subject { get "/admin/authors/search?term=A&skip_default_scopes=true" }

      it 'should have all records' do
        subject
        expect(response_json.size).to eq 2
      end
    end

    context 'when defined default_scope as array' do
      let!(:record_deleted) { FactoryBot.create(:author, :personal, :deleted) }
      before do
        ActiveAdmin.register Author do; active_admin_search! default_scope: [:personal, :not_delete] end
        Rails.application.reload_routes!
      end
      subject { get '/admin/authors/search?term=A' }

      it 'should have all records' do
        subject
        expect(response_json.size).to eq 1
      end
    end
  end

  describe 'setting named: scope which pass in url params' do
    context 'when pass scope: personal' do
      subject { get "/admin/authors/search?term=A&scope=personal" }
      before do
        ActiveAdmin.register Author do; active_admin_search! end
        Rails.application.reload_routes!
      end

      it 'should have correct request' do
        subject
        expect(response_json).to match_array hash_including(value: record.id, text: record.display_name)
      end

      it 'should have scoped record only' do
        subject
        expect(response_json.size).to eq 1
        expect(response_json.first.fetch :value).to eq record.id
      end
    end
  end

  describe 'setting named: scope which pass in url params' do
    context 'when pass couple scopes separated coma' do
      let!(:record_deleted) { FactoryBot.create(:author, :personal, :deleted) }
      subject { get "/admin/authors/search?term=A&scope=personal,not_delete" }
      before do
        ActiveAdmin.register Author do; active_admin_search! end
        Rails.application.reload_routes!
      end

      it 'should have correct request' do
        subject
        expect(response_json).to match_array hash_including(value: record.id, text: record.display_name)
      end

      it 'should have scoped record only' do
        subject
        expect(response_json.size).to eq 1
        expect(response_json).to match_array hash_including(
            value: record.id,
            text: record.display_name
        )
      end
    end
  end
end
