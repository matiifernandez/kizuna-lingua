class GrammarPoint < ApplicationRecord
  has_many :topics, through: :topic_grammar_points

  validates :title, presence: true
  validates :level, presence: true
  validates :examples, presence: true
  validates :explanation, presence: true
  validates :language, presence: true

end
