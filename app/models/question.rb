class Question < ActiveRecord::Base
  validates :main_question, presence: true
  attr_accessor :weightage
  belongs_to :author,
    class_name: "User",
    foreign_key: :author_id

  has_many :followers_join,
    class_name: "Following",
    as: :followable

  has_many :followers,
    through: :followers_join,
    source: :follower

  has_many :topics_join,
    class_name: "TopicQuestionJoin",
    foreign_key: :question_id,
    inverse_of: :question

  has_many :topics,
    through: :topics_join,
    source: :topic

  has_many :comments, as: :commentable

  has_many :answers, dependent: :destroy

  has_many :upvotes_join, class_name:"Upvote", as: :upvoteable

  has_many :upvote_users,
    through: :upvotes_join,
    source: :user

  # list but not asked
  has_many :relevant_user_joins,
  class_name: "UserQuestionA2a",
  inverse_of: :question

  has_many :relevant_users,
  through: :relevant_user_joins,
  source: :relevant_user

  def related_questions
    relevant_questions = Question.where({answer_type: self.answer_type, qt_keyword: self.question_type_keyword}).limit(5)

    return relevant_questions
  end

  def create_relevant_users
    num_results = 30
    if self.topic_ids
      a2a_user_ids = Following.where({followable_id: self.topic_ids.first, followable_type: "Topic"}).limit(num_results).pluck(:f_id)
      # a2a_users = a2a_user_ids.map{|user_id| return User.find(user_id)}
    end

    return a2a_user_ids
    ################
    # relevant_users_scores = Hash.new(){0}
    # self.topics.each do |topic|
    #   top_users = TopicUserKnow.where({topic_id: topic.id}).order(:score).limit(5)
    #   top_users.each do |top_user|
    #     relevant_users_scores[top_users.author_id] += top_user.score
    #   end
    # end
    #
    # results = []
    # relevant_users_scores.each do |key, value|
    #   if (results.length < num_results || results.last.values.last < value)
    #     results.pop if results.length >= num_results
    #     results.push({key => value})
    #     results = User.array_sort(results)
    #   end
    # end

    #results.map!{|obj| User.find(obj.keys.first)}

    #return results
  end

  def upvote
    self.upvotes += 1
    self.save!
  end

end
