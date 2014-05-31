class QuestionFollowing < ActiveRecord::Base
  validates :follower, presence: true

  belongs_to :follower,
   class_name: "User",
   foreign_key: :follower_id

  belongs_to :followed_question, 
    class_name: "Question",
    foreign_key: :question_id
end
