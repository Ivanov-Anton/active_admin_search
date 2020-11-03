# frozen_string_literal: true

FactoryBot.define do
  factory :post, class: 'Post' do
    association :author, factory: :author
    sequence(:title) { |n| "Title number #{n}" }
    body { 'SOme long text' }
  end
end
