class Following < ActiveRecord::Base
  validates :follower, presence: true
  after_create :notify 

  belongs_to :follower,
   class_name: "User",
   foreign_key: :f_id

  belongs_to :followable, polymorphic: true

  private
  def notify
    followable_obj = self.followable_type.constantize.find(self.followable_id)
    followable_author_id = ((self.followable_type == "User") ? followable_obj.id : followable_obj.author_id )
    if (self.f_id != followable_author_id)
      Notification.create({notification_kind: "followed", sent_by_id: self.f_id,
         sent_to_id: followable_author_id, about_object: followable_obj}) 
    end
  end
end
