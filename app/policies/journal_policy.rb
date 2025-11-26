class JournalPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      # It will only return journals from the current user's partnership.
      scope.where(user: user).order(created_at: :desc)
    end
  end

  def show?
    # The user must be in a partnership, and the journal must belong to that partnership.
    user.partnership && record.partnership == user.partnership
  end

  def create?
    user.partnership.present?
  end

  def update?
    # A user can update a journal if:
    # It belongs to their partnership.
    # It was not created by themselves. (Can only give feedback to partner's journals)
    user.partnership && record.partnership == user.partnership && record.user != user
  end
end
