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
    authorize @topic
  end
end
