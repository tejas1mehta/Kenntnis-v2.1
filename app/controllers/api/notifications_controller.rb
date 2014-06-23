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
      status = (all_data == "AllNotifications") ? [true, false] : [false]
      @notifications = Notification.get_notifications(current_user.id, status)
      
      render :index
    end

    def clear
      notifications = Notification.where({sent_to_id: current_user.id, viewed: false})
      notifications.each do |notfn|
        notfn.viewed = true
        notfn.save!
      end
      head :ok
    end

    private
    
    def notification_params
      params.require(:notification).permit(:notification_body, :sent_by_id, :sent_to_id,
       :about_object_id, :about_object_type, :viewed) 
    end 

    def all_data
      params.permit(:data_to_fetch).values.first
    end
  end
end