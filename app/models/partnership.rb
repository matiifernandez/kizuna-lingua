class Partnership < ApplicationRecord
  belongs_to :user_one, class_name: "User"
  belongs_to :user_two, class_name: "User"
  has_many :journals
  has_many :partnership_topics
  has_many :topics, through: :partnership_topics

  def partner_of(current_user)
    if current_user == user_one
      user_two
    elsif current_user == user_two
      user_one
    else
      nil
    end
  end
end
