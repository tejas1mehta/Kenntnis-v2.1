class Answer < ActiveRecord::Base
  validates :main_answer, :question, :author, presence: true
  attr_accessor :weightage
  after_create :notify 

  # searchable do
  #   text :main_answer, boost: 2.0
  #   text :author
  # end

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

  def self.get_feed_ans(followed_user_ids, last_an_time)
    Answer.find_by_sql ["SELECT an_list.id AS id,
                MAX(an_list.main_answer) AS main_answer,
                MAX(an_list.question_id) AS question_id,
                MAX(an_list.author_id) AS author_id,
                MAX(an_list.upvotes) AS upvotes,
                MAX(an_list.created_at) AS created_at,
                MAX(sort_time_c) AS sort_time
                FROM (
                SELECT answers.*, upvotes.created_at AS sort_time_c
                FROM answers
                INNER JOIN upvotes
                ON (upvotes.upvoteable_id = answers.id AND upvotes.upvoteable_type = 'Answer')
                WHERE (upvotes.user_id IN (:followed_ids)) 
                UNION
                SELECT answers.*, answers.created_at AS sort_time_c
                        FROM answers 
                        WHERE (answers.author_id IN (:followed_ids)))  AS an_list
                GROUP BY an_list.id
                HAVING max(sort_time_c) < :last_feed_an_time
                ORDER BY max(sort_time_c) DESC
                LIMIT 10",  {followed_ids: followed_user_ids, last_feed_an_time: last_an_time} ]
    
  end

  def self.get_ans(followed_user_ids, last_an_time)
    Answer.find_by_sql ["SELECT an_list.id AS id,
                MAX(an_list.main_answer) AS main_answer,
                MAX(an_list.question_id) AS question_id,
                MAX(an_list.author_id) AS author_id,
                MAX(an_list.upvotes) AS upvotes,
                MAX(an_list.created_at) AS created_at,
                MAX(sort_time_c) AS sort_time
                FROM (
                SELECT answers.*, upvotes.created_at AS sort_time_c
                FROM answers
                INNER JOIN upvotes
                ON (upvotes.upvoteable_id = answers.id AND upvotes.upvoteable_type = 'Answer')
                WHERE (upvotes.user_id IN (:followed_ids)) 
                UNION
                SELECT answers.*, answers.created_at AS sort_time_c
                        FROM answers 
                        WHERE (answers.author_id IN (:followed_ids)))  AS an_list
                GROUP BY an_list.id
                HAVING max(sort_time_c) < :last_feed_an_time
                ORDER BY max(sort_time_c) DESC
                ",  {followed_ids: followed_user_ids, last_feed_an_time: last_an_time} ]
    
  end

  private
  def notify
    if (self.question.author_id != self.author_id)
    Notification.create({notification_kind: "added an answer to", sent_by_id: self.author_id,
       sent_to_id: self.question.author_id, about_object: self.question})
    end
    # self.question.followers.each do |qn_follower|
    #   Notification.create({notification_kind: "Created on question followed", sent_by_id: self.author_id,
    #    sent_to_id: qn_follower.id, about_object: self})
    # end
  end
end

