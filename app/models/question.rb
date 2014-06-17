class Question < ActiveRecord::Base
  validates :main_question, presence: true
  attr_accessor :weightage
  # searchable do
  #   text :main_question, boost: 2.0
  #   text :author
  # end
  
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

  def self.get_feed_qns(followed_user_ids, followed_topic_ids, last_qn_time)
    feed_qns = Question.find_by_sql ["SELECT qn_list.id AS id,
              MAX(qn_list.main_question) AS main_question,
              MAX(qn_list.description) AS description,
              MAX(qn_list.author_id) AS author_id,
              MAX(qn_list.upvotes) AS upvotes,
              MAX(qn_list.created_at) AS created_at,
              MAX(sort_time_c) AS sort_time
              FROM (
              SELECT questions.*, upvotes.created_at AS sort_time_c
              FROM questions
              INNER JOIN upvotes
              ON (upvotes.upvoteable_id = questions.id AND upvotes.upvoteable_type = 'Question')
              WHERE (upvotes.user_id IN (:followed_ids)) 
              UNION
              SELECT questions.*, followings.created_at AS sort_time_c
              FROM questions
              INNER JOIN followings
              ON (followings.followable_id = questions.id AND followings.followable_type = 'Question')
              WHERE (followings.f_id IN (:followed_ids))
              UNION
              SELECT questions.*, questions.created_at AS sort_time_c
                      FROM questions 
                      WHERE (questions.author_id IN (:followed_ids))
              UNION
              SELECT questions.*, topic_question_joins.created_at AS sort_time_c
              FROM questions
              INNER JOIN topic_question_joins
              ON (questions.id = topic_question_joins.question_id)
              WHERE (topic_question_joins.topic_id IN (:topic_ids)) )  AS qn_list
              GROUP BY qn_list.id
              HAVING max(sort_time_c) < :last_feed_qn_time
              ORDER BY max(sort_time_c) DESC
              LIMIT 5",  {followed_ids: followed_user_ids, topic_ids: followed_topic_ids, last_feed_qn_time: last_qn_time} ]
    return feed_qns
  end

  def self.get_profile_qns(user_id)
     Question.find_by_sql ["SELECT qn_list.id AS id,
                  MAX(qn_list.main_question) AS main_question,
                  MAX(qn_list.description) AS description,
                  MAX(qn_list.author_id) AS author_id,
                  MAX(qn_list.upvotes) AS upvotes,
                  MAX(qn_list.created_at) AS created_at,
                  MAX(sort_time_c) AS sort_time
                FROM (
                SELECT questions.*, upvotes.created_at AS sort_time_c
                  FROM questions
                  INNER JOIN upvotes
                  ON (upvotes.upvoteable_id = questions.id AND upvotes.upvoteable_type = 'Question')
                  WHERE (upvotes.user_id IN (:profile_user_id)) 
                UNION
                SELECT questions.*, followings.created_at AS sort_time_c
                  FROM questions
                  INNER JOIN followings
                  ON (followings.followable_id = questions.id AND followings.followable_type = 'Question')
                  WHERE (followings.f_id IN (:profile_user_id))
                UNION
                SELECT questions.*, questions.created_at AS sort_time_c
                  FROM questions 
                  WHERE (questions.author_id IN (:profile_user_id)) )  AS qn_list
                GROUP BY qn_list.id
                ORDER BY max(sort_time_c) DESC", {profile_user_id: [user_id]} ]
  end

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
