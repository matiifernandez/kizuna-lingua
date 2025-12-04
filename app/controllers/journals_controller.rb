class JournalsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_journal, only: [:show, :update]
  def index
    @journals = policy_scope(Journal)
  end

  def show
    authorize @journal
    @partnership_id = current_user.partnership.id
    @challenge_id = @journal.challenge.id
    @transcription_journal = Journal.where(
      partnership_id: @partnership_id,
      challenge_id: @challenge_id
    ).where.not(
      transcript: [nil, '']
    ).first
  end

  def edit
    @journal = Journal.find(params[:id])
    authorize @journal
    @transcript = JSON.parse(@journal.transcript.gsub(/```json\n|```/, ''))
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
      if @journal.user.partner.present?
        JournalSubmittedNotification.with(journal: @journal).deliver(@journal.user.partner)
      end
      redirect_to partnership_journals_path(current_user.partnership), notice: "Journal was created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @journal
    if @journal.update(journal_params)
      if journal_params[:feedback].present? && @journal.user != current_user
        JournalFeedbackNotification.with(journal: @journal).deliver(@journal.user)
      end
      redirect_to dashboard_path, notice: 'Feedback was successfully submitted.'
    else
      render :show, status: :unprocessable_entity
    end
  end

  def add_audio
    @journal = Journal.find(params[:id])
    authorize @journal
    @challenge = @journal.challenge
    @partnership = @journal.partnership
    all_journals = Journal.where(challenge: @challenge, partnership: @partnership)
    partner_journal = all_journals.find_by("id != ?", @journal.id)
    if params[:audio].present?
      @journal.audio.purge
      audio = params[:audio]
      @journal.audio.attach(
        io: audio,
        filename: "audio#{@journal.id}.wav",
        content_type: "audio/wav"
      )
      TranscribeAudioJob.perform_later(@journal.audio.blob.id, "Journal", @journal.id)
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

  def remind_partner
    @journal = Journal.find(params[:id])
    authorize @journal, :remind_partner? # Authorize with a new policy method
    JournalReminderNotification.with(journal: @journal).deliver(@journal.user)
    redirect_to dashboard_path, notice: "Reminder sent to your partner for the journal!"
  end

  private

  def set_journal
    @journal = Journal.find(params[:id])
  end
  def journal_params
    params.require(:journal).permit(:content, :feedback, :conversation_status)
  end
end
