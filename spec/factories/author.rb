# frozen_string_literal: true

FactoryBot.define do
  factory :author, class: 'Author' do
    sequence(:name) { |n| "Author #{n}" }
    last_name { 'RSpec' }

    trait :deleted do
      deleted_at { Time.now.utc }
    end

    trait :personal do
      type_id { Author::CONST::AUTHOR_TYPE_ID_PERSONAL }
    end

    trait :business do
      type_id { Author::CONST::AUTHOR_TYPE_ID_BUSINESS }
    end
  end
end
