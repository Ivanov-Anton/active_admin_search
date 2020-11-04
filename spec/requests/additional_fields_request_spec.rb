# frozen_string_literal: true

RSpec.describe Admin::AuthorsController do
  let!(:deleted_record) { FactoryBot.create(:author, :personal, :deleted) }

  describe 'setting named: additional_fields' do
    context 'defined one field as array in AA page' do
      subject { get '/admin/authors/search?term=' }
      before do
        ActiveAdmin.register Author do; active_admin_search! additional_fields: [:deleted_at], default_scope: :deleted  end
        Rails.application.reload_routes!
      end

      it 'should have additional field' do
        subject
        expect(response_json.size).to eq 1
        expect(response_json).to match_array hash_including(
            value: deleted_record.id,
            text: deleted_record.display_name,
            deleted_at: deleted_record.deleted_at.to_s(:db)
        )
      end
    end

    context 'defined a couple fields as array in AA page' do
      subject { get '/admin/authors/search?term=' }
      before do
        ActiveAdmin.register Author do; active_admin_search! additional_fields: [:deleted_at, :last_name], default_scope: :deleted  end
        Rails.application.reload_routes!
      end

      it 'should have additional fields' do
        subject
        expect(response_json.size).to eq 1
        expect(response_json).to match_array hash_including(
             value: deleted_record.id,
             text: deleted_record.display_name,
             deleted_at: deleted_record.deleted_at.to_s(:db),
             last_name: deleted_record.last_name
        )
      end
    end

    context 'defined as hash in AA page' do
      subject { get '/admin/authors/search?term=' }
      before do
        ActiveAdmin.register Author do; active_admin_search! additional_fields: :deleted_at, default_scope: :deleted  end
        Rails.application.reload_routes!
      end

      it 'should have additional fields' do
        subject
        expect(response_json.size).to eq 1
        expect(response_json).to match_array hash_including(
           value: deleted_record.id,
           text: deleted_record.display_name,
           deleted_at: deleted_record.deleted_at.to_s(:db)
        )
      end
    end

    context 'defined additional field that not present in model' do
      subject { get '/admin/authors/search?term=' }
      before do
        ActiveAdmin.register Author do; active_admin_search! additional_fields: :not_present_in_model, default_scope: :deleted  end
        Rails.application.reload_routes!
      end

      it 'should have additional fields' do
        expect { subject }.to raise_error NoMethodError
      end
    end
  end
end
