# frozen_string_literal: true

class Author < ApplicationRecord
  has_many :posts
  validates :name, presence: true, uniqueness: true

  def display_name
    id.to_s + ' ' + name.to_s
  end
end
