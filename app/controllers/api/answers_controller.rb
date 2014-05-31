module Api
  class AnswersController < ApplicationController

    def create
      @answer = Answer.new(answer_params)

      if @answer.save
        render json: @answer
      else
      end
    end

    def show
      @answer = Answer.find(params[:id])
      if @answer
        render :show #json: @answer
      else
      end
    end

    def destroy
      @answer = Answer.find(params[:id])
      @answer.destroy!

      head :ok
    end

    def update
      @answer = Answer.find(params[:id])

      if @answer.update_attributes(answer_params)
        render json: @answer
      end
    end

    private
    def answer_params
      params.require(:answer).permit(:main_answer, :question_id).merge({author_id: current_user.id})
    end

  end
end