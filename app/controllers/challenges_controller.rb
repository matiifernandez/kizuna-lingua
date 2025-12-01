class ChallengesController < ApplicationController

  def show
    @topic = Topic.find(params[:id])
    @challenge = Challenge.find(params[:id])
    @journal = @challenge.journal
    @partner_journal = @challenge.partner_journal(current_user)
    @partnership = current_user.partnership

    user_level = current_user.learning_level
    user_language = current_user.learning_language
    level_order = ['n5', 'n4', 'a1', 'a2', 'beginner', 'n3', 'n2', 'b1', 'b2', 'intermediate', 'n1', 'c1', 'c2', 'advanced', 'fluent']
    @grammar_points = @topic.grammar_points
                            .where(language: user_language, level: user_level)
                            .sort_by { |gp| level_order.index(gp.level.downcase) || 999 }

    authorize @challenge
  end
end
