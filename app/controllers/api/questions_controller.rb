module Api
  class QuestionsController < ApplicationController
    before_action :require_login, except: [:show]

    def create
      @question = Question.new(question_params)
      @question.relevant_user_ids = @question.create_relevant_users
      if @question.save
        render :show
      else
      end
    end

    def show
      @question = Question.find(params[:id])
      if @question
        render :show
      else
      end
    end

    def destroy
      @question = Question.find(params[:id])
      @question.destroy!

      head :ok
    end

    def update
      @question = Question.find(params[:id])
      if @question.update_attributes(update_question_params)
        render :show
      end
    end

    private
    def question_params
      params.require(:question).permit(:main_question, :description, :topic_ids => []).merge({author_id: current_user.id, topic_ids: params.require(:topic_ids)})
    end

    def update_question_params
      params.require(:question).permit(:main_question, :description)
    end
  end
end