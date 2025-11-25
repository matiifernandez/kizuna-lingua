class Topic < ApplicationRecord
  has_many :partnerships, through: :partnership_topics
  has_many :grammar_points, through: :topic_grammar_points
  has_many :challenges

  validates :name, presence: true, uniqueness: true
  validates :content, presence: true
end
