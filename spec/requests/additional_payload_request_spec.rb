# frozen_string_literal: true

RSpec.describe 'DSL option :additional_payload', type: :request do
  let!(:deleted_record) { FactoryBot.create(:author, :personal, :deleted) }

  context 'when defined one field as array in AA page' do
    subject { get '/admin/additional_payloads/search?term=Author' }

    let(:expected_hash_response) do
      {
        value: deleted_record.id,
        text: deleted_record.display_name,
        deleted_at: deleted_record.deleted_at.to_s(:db)
      }
    end

    before do
      ActiveAdmin.register Author, as: 'additional_payload' do
        active_admin_search! additional_payload: [:deleted_at], default_scope: :deleted
      end
      Rails.application.reload_routes!
    end

    it 'has correct record count' do
      subject
      expect(response_json.size).to eq 1
    end

    it 'has additional field' do
      subject
      expect(response_json).to match_array hash_including(expected_hash_response)
    end
  end

  context 'when defined a couple payload as array in AA page' do
    subject { get '/admin/additional_payloads/search?term=Author' }

    let(:expected_hash_response) do
      {
        value: deleted_record.id,
        text: deleted_record.display_name,
        deleted_at: deleted_record.deleted_at.to_s(:db),
        last_name: deleted_record.last_name
      }
    end

    before do
      ActiveAdmin.register Author, as: 'additional_payload' do
        active_admin_search! additional_payload: %i[deleted_at last_name], default_scope: :deleted
      end
      Rails.application.reload_routes!
    end

    it 'has correct record count' do
      subject
      expect(response_json.size).to eq 1
    end

    it 'has additional fields' do
      subject
      expect(response_json).to match_array hash_including(expected_hash_response)
    end
  end

  context 'when defined as symbol' do
    subject { get '/admin/additional_payloads/search?term=Author' }

    let(:expected_hash_response) do
      {
        value: deleted_record.id,
        text: deleted_record.display_name,
        deleted_at: deleted_record.deleted_at.to_s(:db)
      }
    end

    before do
      ActiveAdmin.register Author, as: 'additional_payload' do
        active_admin_search! additional_payload: :deleted_at, default_scope: :deleted
      end
      Rails.application.reload_routes!
    end

    it 'has correct record count' do
      subject
      expect(response_json.size).to eq 1
    end

    it 'has additional payload' do
      subject
      expect(response_json).to match_array hash_including(expected_hash_response)
    end
  end

  context 'when defined method instead field in AA page' do
    subject { get '/admin/additional_payloads/search?term=Author' }

    let(:expected_hash_response) do
      {
        value: deleted_record.id,
        text: deleted_record.display_name,
        display_name: deleted_record.display_name
      }
    end

    before do
      ActiveAdmin.register Author, as: 'additional_payload' do
        active_admin_search! additional_payload: :display_name, default_scope: :deleted
      end
      Rails.application.reload_routes!
    end

    it 'has correct record count' do
      subject
      expect(response_json.size).to eq 1
    end

    it 'has additional fields' do
      subject
      expect(response_json).to match_array hash_including(expected_hash_response)
    end
  end

  context 'when defined additional field that not present in model' do
    subject { get '/admin/additional_payloads/search?term=Author' }

    before do
      ActiveAdmin.register Author, as: 'additional_payload' do
        active_admin_search! additional_payload: :not_present_in_model, default_scope: :deleted
      end
      Rails.application.reload_routes!
    end

    it 'has additional fields' do
      expect { subject }.to raise_error NoMethodError
    end
  end

  context 'when defined additional payload as lambda' do
    subject { get '/admin/additional_payloads/search?term=Author' }

    let(:expected_hash_response) do
      {
        value: deleted_record.id,
        text: deleted_record.display_name,
        custom_field_name: deleted_record.display_name,
        id_field: deleted_record.id
      }
    end

    before do
      ActiveAdmin.register Author, as: 'additional_payload' do
        active_admin_search! additional_payload: lambda { |record|
          { custom_field_name: record.display_name, id_field: record.id }
        }, default_scope: :deleted
      end
      Rails.application.reload_routes!
    end

    it 'has correct record count' do
      subject
      expect(response_json.size).to eq 1
    end

    it 'has additional payload' do
      subject
      expect(response_json).to match_array hash_including(expected_hash_response)
    end
  end
end
