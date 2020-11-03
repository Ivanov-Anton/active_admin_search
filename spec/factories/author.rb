# frozen_string_literal: true

FactoryBot.define do
  factory :author, class: 'Author' do
    sequence(:name) { |n| "Author #{n}" }
    last_name { 'RSpec' }
  end
end
