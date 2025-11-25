class Challenge < ApplicationRecord
  belongs_to :topic
  has_one :journal

  validates :content, presence: true
  validates :conversation, presence: true
end
