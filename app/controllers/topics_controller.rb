class TopicsController < ApplicationController
  def index
    base_scope = policy_scope(Topic)
    search_query = params.dig(:search, :query)
    if search_query.present?
      @topics = base_scope.where("name ILIKE ?", "%#{search_query}%").order(created_at: :desc)
    else
      @topics = base_scope.order(created_at: :desc)
    end
    @partnership = current_user.partnership
    @partnership_topic = PartnershipTopic.new

    # Get status for each topic for the current partnership
    if @partnership
      @topic_statuses = PartnershipTopic.where(partnership: @partnership)
                                        .index_by(&:topic_id)
    else
      @topic_statuses = {}
    end

    # Filter by status if specified
    if params[:status].present?
      @topics = @topics.to_a.select do |topic|
        topic_status = @topic_statuses[topic.id]&.status || "not started"
        case params[:status]
        when "not_started"
          topic_status == "not started"
        when "in_progress"
          topic_status == "in progress"
        when "completed"
          topic_status == "completed"
        else
          true
        end
      end
    end
  end

  def show
    @topic = Topic.find(params[:id])
    user_language = current_user.learning_language
    @user_level = current_user.learning_level.downcase
    @filtered_grammar_points = @topic.grammar_points
                                 .where(language: user_language)
                                 .where(level: @user_level)
                                 .order(:id)

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
    # @grammar_points = @topic.grammar_points.where("level ILIKE ?", "%#{search_level}%").where(language: user_language)

    @user_level_terms = level_search_terms

    level_order = ['n5', 'n4', 'a1', 'a2', 'beginner', 'n3', 'n2', 'b1', 'b2', 'intermediate', 'n1', 'c1', 'c2', 'advanced', 'fluent']

    @all_grammar_points_by_level = @topic.grammar_points.where(language: user_language).group_by(&:level).sort_by { |level, _| level_order.index(level.downcase) || 999 }.to_h

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
