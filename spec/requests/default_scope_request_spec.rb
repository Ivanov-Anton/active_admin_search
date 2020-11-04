# frozen_string_literal: true

RSpec.describe Admin::AuthorsController do
  subject { get "/admin/authors/search?term=" }
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
      subject { get "/admin/authors/search?term=&skip_default_scopes=true" }

      it 'should have all records' do
        subject
        expect(response_json.size).to eq 2
      end
    end

    # TODO not work this example need to implement
    xcontext 'when defined default_scope as array' do
      before do
        ActiveAdmin.register Author do; active_admin_search! default_scope: [:personal, :business] end
        Rails.application.reload_routes!
      end
      subject { get '/admin/authors/search?term=' }

      it 'should have all records' do
        subject
        expect(response_json.size).to eq 2
      end
    end
  end
end
