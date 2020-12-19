# frozen_string_literal: true

module TagModelExt
  extend ActiveSupport::Concern

  included do
    belongs_to :article, class_name: 'Article'

    def display_name
      "#{id} #{name}"
    end

    scope :visible, -> { where(visible: true) }
  end
end
