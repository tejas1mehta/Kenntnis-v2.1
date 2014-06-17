class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include SessionsHelper

  protect_from_forgery with: :exception

  def require_login
    render json: "You need to be logged in!"  unless current_user
  end

end
