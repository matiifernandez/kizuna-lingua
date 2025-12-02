class PartnershipTopic < ApplicationRecord
  belongs_to :partnership
  belongs_to :topic

  before_create :set_default_status

  def set_default_status
    self.status ||= "in progress"
  end
end
