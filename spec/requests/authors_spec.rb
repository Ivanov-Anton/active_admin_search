# frozen_string_literal: true

RSpec.describe Admin::AuthorsController do
  let(:term) { nil }
  subject { get "/admin/authors/search?term=#{term || ''}" }
  let!(:record) { FactoryBot.create(:author, name: 'RSpec') }

  context 'when empty request' do
    context 'get /admin/authors/search?term=' do
      it 'should response all records' do
        expect { subject }.to make_database_queries count: 1
        expect(response_json.size).to eq 1
      end
    end

    context 'get /admin/authors/search' do
      subject { get '/admin/authors/search' }

      it 'should response all records' do
        expect { subject }.to_not make_database_queries
        expect(response_json.size).to eq 0
      end
    end
  end

  context 'with key term and search by entire name' do
    let(:term) { 'RSpec' }

    it 'should find record' do
      subject
      expect(response_json.size).to eq 1
      expect(response_json).to match_array hash_including(value: 1, text: '1 RSpec')
    end
  end

  context 'with key term and use prefix "id:" and search by id' do
    let(:term) { "id:#{record.id}" }

    it 'should find record' do
      subject
      expect(response_json.size).to eq 1
      expect(response_json).to match_array hash_including(value: 1, text: '1 RSpec')
    end
  end

  context 'with scope given throught url' do
    let!(:deleted_record) { FactoryBot.create(:author, :deleted, name: 'RSpec 123') }
    subject { get "/admin/authors/search?term=RSpec&scope=not_delete" }

    it 'should find scoped record' do
      expect { subject }.to make_database_queries(matching: 'SELECT "authors".* FROM "authors" WHERE "authors"."deleted_at" IS NULL ORDER BY "authors"."id" DESC')
      expect(response_json.size).to eq 1
      expect(response_json).to match_array hash_including(value: record.id, text: record.display_name)
    end
  end

  # TODO not implement yet
  xcontext 'with scope list given throught url' do
    let!(:deleted_record) { FactoryBot.create(:author, :deleted, name: 'RSpec 123') }
    subject { get "/admin/authors/search?term=RSpec&scope=not_delete,personal" }

    it 'should find scoped record' do
      # expect { subject }.to make_database_queries(count: 1)
      # expect(response_json.size).to eq 1
      # expect(response_json).to match_array hash_including(value: record.id, text: record.display_name)
    end
  end

  context 'with feature: skip_default_scopes' do
    let!(:personal_record) { FactoryBot.create(:author, :personal, name: 'Personal Author name') }
    let!(:business_record) { FactoryBot.create_list(:author, 3, :business) }
    let!(:deleted_record) { FactoryBot.create(:author, :deleted, :personal, name: 'RSpec 123') }
    before do
      ActiveAdmin.register Author do; active_admin_search! default_scope: :personal end
      Rails.application.reload_routes!
    end

    context 'with default scope defined as argument' do
      subject { get "/admin/authors/search?term=Author" }

      it 'should find scoped record' do
        expect { subject }.to make_database_queries count: 1
        expect(response_json.size).to eq 2
        expect(response_json).to match_array [
          hash_including(value: personal_record.id, text: personal_record.display_name),
          hash_including(value: deleted_record.id, text: deleted_record.display_name)
        ]
      end
    end

    context 'with default scope defined as argument and override them throught url' do
      subject { get "/admin/authors/search?term=&skip_default_scopes=true&scope=deleted" }

      it 'should find scoped record' do
        expected_q = 'SELECT "authors".* FROM "authors" WHERE "authors"."deleted_at" IS NOT NULL ORDER BY "authors"."id" DESC'
        expect { subject }.to make_database_queries count: 1, matches: expected_q
        expect(response_json.size).to eq 1
        expect(response_json).to match_array hash_including(value: deleted_record.id)
      end
    end
  end
end
