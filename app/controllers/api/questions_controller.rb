module Api
  class QuestionsController < ApplicationController

    def create
      # debugger
      @question = Question.new(question_params)
      @question.relevant_user_ids = @question.create_relevant_users

      
      if @question.save
        render :show
      else
      end
    end

    def show
      @question = Question.find(params[:id])
      # debugger
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

      if @question.update_attributes(question_params)
        render :show
      end
    end

    private
    def question_params
      # add topics
      params.require(:question).permit(:main_question, :description, :topic_ids => []).merge({author_id: current_user.id, topic_ids: params.require(:topic_ids)})
    end
  end
end