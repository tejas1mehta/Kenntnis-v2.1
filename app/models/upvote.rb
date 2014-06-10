class Upvote < ActiveRecord::Base
  validates :user, presence: true
#   validates :user, uniqueness: {scope: :upvotable}
  after_create :add_vote 
  belongs_to :user

  belongs_to :upvoteable, polymorphic: true

  private
  def add_vote
    self.upvoteable_type.constantize.find(self.upvoteable_id).upvote
  end
end
