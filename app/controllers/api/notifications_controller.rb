module Api
  class NotificationsController < ApplicationController
    def create
      @notification = Notification.new(notification_params)

      if @notification.save
        render json: @notification
      else
        # Add error and send
      end
    end

    def destroy
      @notification = Notification.find(params[:id])
      @notification.destroy

      head :ok
    end

    def index
      @notifications = current_user.notifications
      render json: @notifications
    end

    private
    
    def notification_params
      params.require(:notification).permit(:notification_body, :sent_by_id, :sent_to_id,
       :about_object_id, :about_object_type, :viewed) 
    end 
  end
end