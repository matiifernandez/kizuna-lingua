class TopicsController < ApplicationController
  def index
    @topics = policy_scope(Topic)
    @partnership = current_user.partnership
    @partnership_topic = PartnershipTopic.new
  end

  def show
    @topic = Topic.find(params[:id])
    user_language = current_user.learning_language

    level_search_terms = case current_user.learning_level.downcase
                        when 'fluent'
                          ['n1', 'c1', 'c2', 'advanced']
                        when 'intermediate'
                          ['n3', 'n2', 'b1', 'b2', 'intermediate']
                        when 'beginner'
                          ['n5', 'n4', 'a1', 'a2', 'beginner']
                        else
                          [current_user.learning_level]
                        end

    level_conditions = level_search_terms.map { |term| "level ILIKE ?" }.join(' OR ')
    level_values = level_search_terms.map { |term| "%#{term}%" }

    @grammar_points = @topic.grammar_points
                            .where(level_conditions, *level_values)
                            .where(language: user_language)

    @challenge = @topic.challenges.first
    @journal = Journal.new
    authorize @topic
  end

  def generate
    authorize Topic, :generate?
    topic_title = params[:topic][:name]
    result = TopicGenerationService.call(current_user, topic_title)
    if result[:success]
      redirect_to topic_path(result[:topic]), notice: "Topic '#{result[:topic].name}' generated successfully."
    else
      redirect_to topics_path, alert: "Error generating topic: #{result[:error]}"
    end
  end
end
