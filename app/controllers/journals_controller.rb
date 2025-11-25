class JournalsController < ApplicationController
  before_action :authenticate_user!
  def index
    @journals = policy_scope(Journal)
  end

  def show
  end

  def create
  end

  def update
  end
  private

  def journal_params
    params.require(:journal).permit(:content, :feedback, :conversation_status)
  end
end
