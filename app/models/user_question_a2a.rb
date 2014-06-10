class UserQuestionA2a < ActiveRecord::Base
  belongs_to :question

  belongs_to :relevant_user,
   class_name: "User",
    foreign_key: :relevant_user_id
end
