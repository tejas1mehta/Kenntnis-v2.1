module Api
  class DownvotesController < ApplicationController

    def create
      @downvote = Downvote.new(downvote_params)

      if @downvote.save
        downvote_params[:dnvoteable_type].constantize.find(:dnvoteable_id).downvotes += 1
        render json: @downvote
      else
      end
    end

    def destroy
      @downvote = Downvote.find(params[:id])
      @downvote.destroy!

      head :ok
    end

    private  
    def downvote_params
      params.require(:downvote).permit(:dnvoteable_id, :dnvoteable_type).merge({user_id: current_user.id})
    end

  end
end
