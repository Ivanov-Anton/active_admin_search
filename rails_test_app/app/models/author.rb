# frozen_string_literal: true
#--------------------------------
# name          string
# last_name     string
# deleted_at    date
class Author < ApplicationRecord
  has_many :articles

  module CONST
    AUTHOR_TYPE_ID_PERSONAL = 1
    AUTHOR_TYPE_ID_BUSINESS = 2

    AUTHOR_TYPE_IDS = {
        AUTHOR_TYPE_ID_BUSINESS => 'Business',
        AUTHOR_TYPE_ID_PERSONAL => 'Personal'
    }.freeze
  end

  validates :name, presence: true, uniqueness: true
  with_options(on: :create) do
    validates :type_id, inclusion: { in: CONST::AUTHOR_TYPE_IDS.keys }, allow_nil: true
  end

  def display_name
    id.to_s + ' ' + name.to_s
  end

  def display_name_ajax
    id.to_s + ' ' + name.to_s + '_ajax'
  end

  def display_ajax
    id.to_s + ' ' + name.to_s + 'DELETED'
  end

  def display_any_tag_name
    articles.take.tags.take.name.to_s
  end

  scope :personal, -> { where(type_id: CONST::AUTHOR_TYPE_ID_PERSONAL) }
  scope :business, -> { where(type_id: CONST::AUTHOR_TYPE_ID_BUSINESS) }
  scope :deleted, -> { where.not(deleted_at: nil) }
  scope :not_delete, -> { where(deleted_at: nil) }

  scope :term, -> (value) do
    ransack(name_contains: value).result
  end

  scope :term2, -> (value) do
    ransack(name_contains: value).result
  end

  def self.ransackable_scopes(_auth = nil)
    %w[term term2]
  end
end
