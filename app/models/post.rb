# frozen_string_literal: true

class Post < ApplicationRecord
  belongs_to :author
  validates :title, presence: true

  def display_name
    id.to_s + ' ' + title.to_s
  end
end
