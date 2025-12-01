class ChallengesController < ApplicationController

  def show
    @topic = Topic.find(params[:id])
    @challenge = Challenge.find(params[:id])
    @journal = @challenge.journal
    @partner_journal = @challenge.partner_journal(current_user)
    @partnership = current_user.partnership
    authorize @challenge
  end
end
