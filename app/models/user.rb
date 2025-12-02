class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :validatable
  has_one :partnership_as_one, class_name: "Partnership", foreign_key: "user_one_id"
  has_one :partnership_as_two, class_name: "Partnership", foreign_key: "user_two_id"
  has_many :journals
  has_many :invite_codes
  has_many :notifications, as: :recipient, dependent: :destroy, class_name: "Noticed::Notification"
  has_one_attached :photo

  def partnership
    partnership_as_one || partnership_as_two
  end

  def partner
    partnership&.partner_of(self)
  end
end
