class JournalsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_journal, only: [:show, :update]
  def index
    @journals = policy_scope(Journal)
  end

  def show
    authorize @journal
  end

  def new
    @challenge = Challenge.find(params[:challenge_id])
    @journal = Journal.new
    authorize @journal
  end
  def create
    @challenge = Challenge.find(params[:challenge_id])
    @journal = Journal.new(journal_params)
    @journal.challenge = @challenge
    @journal.user = current_user
    @journal.partnership = current_user.partnership
    authorize @journal

    if @journal.save
      redirect_to partnership_journals_path(current_user.partnership), notice: "Journal was created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @journal
    if @journal.update(journal_params)
      redirect_to partnership_journals_path(@journal.partnership), notice: 'Feedback was successfully submitted.'
    else
      render :show, status: :unprocessable_entity
    end
  end

  def complete_conversation
    @journal = Journal.find(params[:id])
    authorize @journal
    @challenge = @journal.challenge
    @partnership = @journal.partnership
    if @journal.update(conversation_status: true)
      all_journals = Journal.where(challenge: @challenge, partnership: @partnership)
      partner_journal = all_journals.find_by("id != ?", @journal.id)
      if partner_journal.present?
        partner_journal.update_column(:conversation_status, true)
      end
      redirect_to dashboard_path, notice: "Conversation marked as complete."
    else
      redirect_to dashboard_path, alert: "Failed to mark conversation as complete."
    end
  end

  private

  def set_journal
    @journal = Journal.find(params[:id])
  end
  def journal_params
    params.require(:journal).permit(:content, :feedback, :conversation_status)
  end
end
