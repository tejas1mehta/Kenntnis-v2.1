module Api
  class UpvotesController < ApplicationController

    def create
      @upvote = Upvote.new(upvote_params)
      if @upvote.save
        # upvote_params[:upvoteable_type].constantize.find(:upvoteable_id).upvotes += 1
        render json: @upvote
      else
        render json: { errors: @upvote.errors.full_messages }, status: 422
      end
    end

    def destroy
      @upvote = Upvote.find(params[:id])
      @upvote.destroy!

      head :ok
    end

    private
    def upvote_params
      params.require(:upvote).permit(:upvoteable_id, :upvoteable_type).merge({user_id: current_user.id})
    end

  end
end