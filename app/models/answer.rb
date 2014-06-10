class Answer < ActiveRecord::Base
  validates :main_answer, :question, :author, presence: true
  attr_accessor :weightage

  has_many :comments, as: :commentable

  belongs_to :question

  belongs_to :author,
   class_name: "User",
   foreign_key: :author_id

  has_many :upvotes_join, class_name:"Upvote", as: :upvoteable

  has_many :upvote_users,
     through: :upvotes_join,
     source: :user

  def upvote
    self.upvotes += 1
    self.save!
  end
end
