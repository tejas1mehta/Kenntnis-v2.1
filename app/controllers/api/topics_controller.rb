module Api
  class TopicsController < ApplicationController
    before_action :require_login

    def index
      @topics = Topic.all

      render json: @topics
    end

    def create
      @topic = Topic.new(topic_params)

      if @topic.save
        render json: @topic
      else
      end
    end

    def show
      @topic = Topic.find(params[:id])
      if @topic
        render :show #json: @topic
      else
      end
    end

    def destroy
      @topic = Topic.find(params[:id])
      @topic.destroy!

      head :ok
    end

    def update
      @topic = Topic.find(params[:id])

      if @topic.update_attributes(topic_params)
        render :show
      end
    end

    private
    def topic_params
      params.require(:topic).permit(:title, :description).merge({author_id: current_user.id})
    end

  end
end