class Journal < ApplicationRecord
  belongs_to :user
  belongs_to :challenge
  belongs_to :partnership
  has_one_attached :audio
  has_many :comments
end
