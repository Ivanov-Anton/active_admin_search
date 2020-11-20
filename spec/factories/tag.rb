# frozen_string_literal: true

FactoryBot.define do
  factory :tag, class: 'Tag' do
    name { 'red' }
    visible { true }
  end
end
