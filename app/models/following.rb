class Following < ActiveRecord::Base
  validates :follower, presence: true

  belongs_to :follower,
   class_name: "User",
   foreign_key: :f_id

  belongs_to :followable, polymorphic: true

end
