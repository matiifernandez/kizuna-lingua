class PartnershipTopicsController < ApplicationController
  def create
    @topic = Topic.find(params[:topic_id])
    @partnership_topic = PartnershipTopic.new
    @partnership_topic.topic = @topic
    @partnership_topic.partnership = current_user.partnership
    @partnership_topic.status = "in progress"
    authorize @partnership_topic
    if @partnership_topic.save
      redirect_to topic_path(@topic)
    else
      @topics = Topic.all
      render :index, status: :unprocessable_entity
    end
  end

  private

  def partnership_topic_params
    params.require(:partnership_topics).permit(:status, :partnership_id, :topic_id)
  end
end
