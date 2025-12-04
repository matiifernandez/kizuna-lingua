class PartnershipTopicsController < ApplicationController
  def create
    @topic = Topic.find(params[:topic_id])
    @partnership_topic = PartnershipTopic.new
    @partnership_topic.topic = @topic
    @partnership_topic.partnership = current_user.partnership
    @partnership_topic.status = "in progress"
    authorize @partnership_topic
    if @partnership_topic.save
      redirect_to dashboard_path
    else
      @topics = Topic.all
      render :index, status: :unprocessable_entity
    end
  end

  def complete_topic
    @partnership_topic = PartnershipTopic.find(params[:id])
    authorize @partnership_topic
    if @partnership_topic.update!(status: 'completed')
      flash[:notice] = "Congratulations! Topic '#{@partnership_topic.topic.name}' is now complete!"
    else
      flash[:alert] = "Could not mark topic as complete."
    end
    redirect_to dashboard_path
  end

  private

  def partnership_topic_params
    params.require(:partnership_topics).permit(:status, :partnership_id, :topic_id)
  end
end
