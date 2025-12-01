class TopicsController < ApplicationController
  def index
    @topics = policy_scope(Topic)
    @partnership = current_user.partnership
    @partnership_topic = PartnershipTopic.new
  end

  def show
    @topic = Topic.find(params[:id])
    user_language = current_user.learning_language
    search_level = current_user.learning_level.downcase

    @grammar_points = @topic.grammar_points.where("level ILIKE ?", "%#{search_level}%").where(language: user_language)
    @challenge = @topic.challenges.first
    @journal = Journal.new
    authorize @topic
  end

  def generate
    authorize Topic, :generate?
    topic_title = params[:topic][:name]
    GenerateTopicJob.perform_later(current_user, topic_title)
    redirect_to topics_path, notice: 'Topic generation has started. It may take a few seconds to complete and will be on the list soon.'
  end
end
