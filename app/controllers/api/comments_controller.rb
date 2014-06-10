module Api
  class CommentsController < ApplicationController

    def create
      @comment = Comment.new(comment_params)

      if @comment.save
        render json: @comment
      else
      end
    end

    def destroy
      @comment = Comment.find(params[:id])
      @comment.destroy!

      head :ok
    end

    private
    def comment_params
      params.require(:comment).permit(:comment_body, :parent_body_id, :commentable_id, :commentable_type).merge({author_id: current_user.id})
    end

  end
end