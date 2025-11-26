class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :validatable
  has_many :journals, dependent: :destroy

  # A user can be user_one in a partnership.
  has_many :partnerships_as_one, class_name: 'Partnership', foreign_key: 'user_one_id', dependent: :destroy
  # A user can be user_two in a partnership.
  has_many :partnerships_as_two, class_name: 'Partnership', foreign_key: 'user_two_id', dependent: :destroy

  def partnerships
    Partnership.where("user_one_id = :id OR user_two_id = :id", id: id)
  end

  #This is where we find the only partnership a user has for now.
  def partnership
    partnerships.first
  end
end
