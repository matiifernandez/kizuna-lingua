class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: :home
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def home
  end

  def dashboard
    @current_user = current_user
    @partnership = current_user.partnership
    @partner = @partnership.partner_of(current_user)
    @most_recent = PartnershipTopic.where(status: "in progress").order(created_at: :desc)
    if @most_recent.present?
      @most_recent_topic = @most_recent.first.topic
      @challenge = @most_recent_topic.challenges.first
      @my_journal = Journal.find_by(user: current_user, challenge: @challenge, partnership: @partnership)
      @partner_journal = @challenge.partner_journal(current_user)
      @progress_percentage = calculate_progress_percentage(@my_journal, @partner_journal)
    end
    # if @most_recent_topic
    #   @recent_topic = @most_recent_topic.topic
    # end
  end

  private

  def calculate_progress_percentage(my_journal, partner_journal)
    progress = 0
    max_stages = 5
    progress += 1 if my_journal.present?
    progress += 1 if partner_journal.present?
    progress += 1 if my_journal.feedback.present?
    progress += 1 if partner_journal.feedback.present?
    progress += 1 if my_journal.conversation_status.present?
    (progress.to_f / max_stages) * 100
  end

end
