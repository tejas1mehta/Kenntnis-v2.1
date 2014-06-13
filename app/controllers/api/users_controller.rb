module Api
  class UsersController < ApplicationController
    def create
      @user = User.new(user_params)
      if @user.save
        # UserMailer.activation_email(@user).deliver!
        login_user!(@user)
        render json: @user
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
      # debugger
      case data_to_fetch_param
      when "questions_created"
        @results = @user.show_qns_created(last_obj_time_param)
        render :show_objects
      when "answers_created"
        @results = @user.show_ans_created(last_obj_time_param)  
        render :show_objects
      when "followers"
        @results = @user.followers_fn(last_obj_time_param)
        render :show_users
      when "followings"
        @results = @user.followed_users_fn(last_obj_time_param)
        render :show_users
      when "profile_results"
        @results = @user.profile_view(last_obj_time_param)
        render :show
      when "feed_results"
        @results, @last_an_time, @last_qn_time = @user.feed_objects(last_an_time_param, last_qn_time_param)
        @rec_users = @user.rec_users_to_follow(num_scroll_params)
        render :feed
      end
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
      params.require(:user).permit(:email, :name, :about, :location,
      	:education, :employment, :credits, :session_token, :num_credits_ans).merge( params.permit(:password))
    end
    
    def num_scroll_params
      params.permit(:num_scrolls).values.first.to_i
    end

    def last_an_time_param
      params.permit(:last_an_time).values.first
    end

    def last_qn_time_param
      params.permit(:last_qn_time).values.first
    end    

    def last_obj_time_param
      params.permit(:last_obj_time).values.first
    end   

    def data_to_fetch_param
      params.permit(:data_to_fetch).values.first
    end
  end
end