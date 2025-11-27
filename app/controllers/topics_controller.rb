class TopicsController < ApplicationController
  def index
    @topics = policy_scope(Topic)
    @partnership = current_user.partnership
    @partnership_topic = PartnershipTopic.new
  end

  def show
    @topic = Topic.find(params[:id])
    user_level = current_user.learning_level
    user_language = current_user.learning_language
    @grammar_points = @topic.grammar_points.where(level: user_level, language: user_language)
    @challenge = @topic.challenges.first
    @journal = Journal.new
    authorize @topic
  end

  def generate
    topic_title = params[:topic][:name]
    result = TopicGenerationService.call(current_user, topic_title)
    if result[:success]
      redirect_to topic_path(result[:topic]), notice: "Topic '#{result[:topic].name}' generated successfully."
    else
      redirect_to topics_path, alert: "Error generating topic: #{result[:error]}"
    end
  end
end
