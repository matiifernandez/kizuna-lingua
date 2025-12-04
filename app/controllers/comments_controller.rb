class CommentsController < ApplicationController
  def create
    @journal = Journal.find(params[:journal_id])
    @comment = Comment.new(
      user: current_user,
      start_index: comment_params[:start_index],
      end_index: comment_params[:end_index],
      transcript_index: comment_params[:transcript_index],
      content: comment_params[:body]
    )
    authorize @comment
    @comment.journal = @journal

    if @comment.save
      respond_to do |format|
        format.html { redirect_to @journal, notice: "Comment added." }
        format.json { render json: { status: "ok" } }
      end
    else
      respond_to do |format|
        format.html { redirect_to @journal, alert: "Could not save comment." }
        format.json { render json: { status: "error", errors: @comment.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def comment_params
    params.require(:comment).permit(:journal_id, :start_index, :end_index, :transcript_index, :body)
  end
end
