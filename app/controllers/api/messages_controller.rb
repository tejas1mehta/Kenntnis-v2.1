module Api
	class MessagesController < ApplicationController
		def create
			@message = Message.new(message_params)

			if @message.save
				render :index
			else
				# Add error and send
			end
		end

		def show
			@message = Message.find(params[:id])

			render :show
		end

		def destroy
			@message = Message.find(params[:id])
			@message.destroy

			head :ok
		end

		def index
			@sent_messages = current_user.sent_messages
			@received_messages = current_user.received_messages

			@all_messages = @sent_messages + @received_messages
			render :index#json: @all_messages
		end
		private
		
		def message_params
			params.require(:message).permit(:message_body, :sent_by_id, :sent_to_id,
			 :parent_message_id, :subject, :viewed)	
		end	
	end
end