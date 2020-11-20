# frozen_string_literal: true

class Tag < ApplicationRecord
  belongs_to :article, class_name: 'Article'

  def display_name
    id.to_s + ' ' + name.to_s
  end

  scope :visible, -> { where(visible: true) }
end
