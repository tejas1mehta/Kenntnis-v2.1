module Api
  class UsersController < ApplicationController
    def create
      @user = User.new(user_params)
      if @user.save
        # UserMailer.activation_email(@user).deliver!
        render json: @user
        # redirect_to root_url, notice: "Successfully created your account! Check your inbox for an activation email."
        # render partial: "api/sessions/new", locals: { board: @board }
      else
        render json: { errors: @user.errors.full_messages }, status: 422
      end
    end

    def new
      @user = User.new
      render :new
    end

    def userinfo
      @user = User.find(params[:id])
      render :user_info
    end

    def show #User profile
      @user = User.find(params[:id])
      # num_scrolls = params.permit(:num_scrolls).values.first.to_i
      @results = @user.profile_view(num_scrolls_int)
      # debugger
      render :show
    end

    def feed
      # debugger
      @user = User.find(params[:id])
      # num_scrolls = params.permit(:num_scrolls).values.first.to_i
      @results = @user.feed_questions(num_scrolls_int)
      @rec_users = @user.rec_users_to_follow()
      # debugger
      render :feed
    end

    def update
      @user = User.find(params[:id])
      # debugger
      if @user.update_attributes(user_params)
        render json: @user
      else
        render json: { errors: @user.errors.full_messages }, status: 422
      end
    end

    def activate
      @user = User.find_by_activation_token(params[:activation_token])

      # Check for presence of activation token in params to prevent
      # fetching a user from the db that has a nil activation_token
      # for some reason.
      if params[:activation_token] && @user
        @user.activate!
        login_user! @user
        redirect_to @user, notice: "Successfully activated your account!"
      else
        raise ActiveRecord::RecordNotFound.new()
      end
    end

    def search
      search_keywords = params.require(:keywords)

      @results = User.search(search_keywords)
      render :search #json: @results
    end


    private
    def user_params
      # password doesnt show up in user params, removing user
      params.require(:user).permit(:email, :name, :about, :location,
      	:education, :employment, :credits, :session_token, :num_credits_ans).merge( params.permit(:password))
    end

    def num_scrolls_int
      params.permit(:num_scrolls).values.first.to_i
    end
  end
end