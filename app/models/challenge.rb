class Challenge < ApplicationRecord
  belongs_to :topic
  has_one :journal

  validates :content, presence: true
  validates :conversation, presence: true

  def partner_journal(current_user)
    partnership = current_user.partnership
    return nil unless partnership.present?
    partner = partnership.partner_of(current_user)
    return nil unless partner.present?
    Journal.find_by(user: partner, challenge: self, partnership: partnership)
  end
end
