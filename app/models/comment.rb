class Comment < ActiveRecord::Base
  validates :comment_body, presence: true
  belongs_to :commentable, polymorphic: true

  has_many :child_comments, 
    class_name: "Comment",
    foreign_key: :parent_comment_id

  belongs_to :parent_comment,
    class_name: "Comment",
    foreign_key: :parent_comment_id

  belongs_to :author,
    class_name: "User",
    foreign_key: :author_id

  def upvote
    self.upvotes += 1
    self.save!
  end
end
