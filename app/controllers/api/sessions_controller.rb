module Api
  class SessionsController < ApplicationController
    def create
      @user = User.find_by_credentials(
        user_params[:email],
        user_params[:password]
      )
      # debugger
      if @user.nil?
        flash.now[:errors] ||= []
        flash.now << "Login failed. Check yo' self."
        render :new
      elsif !@user.activated?
        redirect_to root_url, alert: "You must activate your account first! Check your email." #Pass in errors to JS
      else
        login_user!(@user)
        render json: @user #:create
        #render "api/users/show"# change to "feed"
      end

    end

    def destroy
      current_user.reset_session_token!
      session[:session_token] = nil
      # debugger
      render json: 1
    end

    private
    def user_params
      params.require(:session).permit(:email, :password)
    end
  end
end