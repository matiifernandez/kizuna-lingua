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
      @partner_journal = @most_recent_topic.challenges.first.partner_journal(current_user)
      @my_journal = @most_recent_topic.challenges.first.journal
    end
    # if @most_recent_topic
    #   @recent_topic = @most_recent_topic.topic
    # end
  end

end
