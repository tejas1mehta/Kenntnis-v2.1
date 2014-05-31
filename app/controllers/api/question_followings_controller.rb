module Api
  class QuestionFollowingsController < ApplicationController

    def create
      @question_following = QuestionFollowing.new(question_following_params)

      if @question_following.save
        render json: @question_following
      else
      end
    end

    def destroy
      @question_following = QuestionFollowing.find(params[:id])
      @question_following.destroy!

      head :ok
    end

    private  
    def question_following_params
      params.require(:question_following).permit(:question_id).merge({follower_id: current_user.id})
    end

  end
end