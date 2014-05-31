module Api
  class FollowingsController < ApplicationController

    def create
      @following = Following.new(following_params)
      if @following.save
        render json: @following
      else
      end
    end

    def destroy
      @following = Following.find(params[:id])
      @following.destroy!
      render json: @following
    end

    private
    def following_params
      params.require(:following).permit(:followable_id, :followable_type).merge({f_id: current_user.id})
    end
  end
end