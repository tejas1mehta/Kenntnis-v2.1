class Upvote < ActiveRecord::Base
  validates :user, presence: true
#   validates :user, uniqueness: {scope: :upvotable}
  after_create :add_vote_and_notify 
  belongs_to :user

  belongs_to :upvoteable, polymorphic: true

  has_one :notification, as: :about_object

  private
  def add_vote_and_notify
    upvoteable_obj = self.upvoteable_type.constantize.find(self.upvoteable_id)
    upvoteable_obj.upvote
    if upvoteable_obj.author_id != self.user_id
      Notification.create({notification_kind: "upvoted", sent_by_id: self.user_id,
       sent_to_id: upvoteable_obj.author_id, about_object: upvoteable_obj})
    end
  end
end
