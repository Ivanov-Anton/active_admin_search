# frozen_string_literal: true

module ArticleModelExt
  extend ActiveSupport::Concern

  included do
    belongs_to :author
    validates :title, presence: true
    has_many :tags, class_name: 'Tag'

    def display_name
      id.to_s + ' ' + title.to_s
    end

    scope :published, -> { where(published: true) }
    scope :visible, -> { where(visible: true) }

    scope :term, ->(value) do
      where('title ILIKE ?', value)
    end
  end
end
