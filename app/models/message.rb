class Message < ActiveRecord::Base
	validates :sent_to, :sent_by, presence: true

	belongs_to :sent_to,
	 class_name: "User",
	 foreign_key: :sent_to_id,
	 inverse_of: :received_messages

	belongs_to :sent_by,
	 class_name: "User",
	 foreign_key: :sent_by_id,
	 inverse_of: :sent_messages	


end
