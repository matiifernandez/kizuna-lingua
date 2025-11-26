class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_one :partnership_as_one, class_name: "Partnership", foreign_key: "user_one_id"
  has_one :partnership_as_two, class_name: "Partnership", foreign_key: "user_two_id"
  has_many :journals

  def partnership
    partnership_as_one || partnership_as_two
  end
end
