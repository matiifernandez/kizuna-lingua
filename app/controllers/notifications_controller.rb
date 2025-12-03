class NotificationsController < ApplicationController
  def index
    @notifications = policy_scope(Noticed::Notification, policy_scope_class: NotificationPolicy::Scope).newest_first
    render partial: "notifications/list", locals: { notifications: @notifications }
  end

  def show
    @notification = Noticed::Notification.find(params[:id])
    authorize @notification, policy_class: NotificationPolicy
    @notification.mark_as_read!

    # Redirect to the journal associated with the notification
    journal = @notification.params[:journal]
    redirect_to partnership_journal_path(journal.partnership, journal)
  end
end

