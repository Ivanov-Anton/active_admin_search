# frozen_string_literal: true

FactoryBot.define do
  factory :article, class: 'Article' do
    association :author, factory: :author
    sequence(:title) { |n| "Title number #{n}" }
    body { 'Some long text' }
  end
end
