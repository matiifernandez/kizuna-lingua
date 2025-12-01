class InviteCode < ApplicationRecord
  belongs_to :user
  before_create :generate_unique_code
  scope :active, -> { where(used: false).where("expires_at > ?", Time.current) }

  private

  def generate_unique_code
    loop do
      self.code = SecureRandom.hex(3).upcase
      break unless InviteCode.exists?(code: self.code)
    end
    self.expires_at = 24.hours.from_now
    self.used = false
  end
end
