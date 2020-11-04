# frozen_string_literal: true

# title       string
# body        text
# author_id   integer
# published   boolean
# visible     boolean
class Post < ApplicationRecord
  belongs_to :author
  validates :title, presence: true

  def display_name
    id.to_s + ' ' + title.to_s
  end

  scope :published, -> { where(published: true) }
  scope :visible, -> { where(visible: true) }
end
