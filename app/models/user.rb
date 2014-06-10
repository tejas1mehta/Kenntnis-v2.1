# == Schema Information
#
# Table name: users
#
#  id               :integer          not null, primary key
#  session_token    :string(255)      not null
#  email            :string(255)      not null
#  password_digest  :string(255)      not null
#  name             :string(255)      not null
#  about            :text
#  location         :string(255)
#  education        :text
#  employment       :text
#  credits          :integer          default(500)
#  num_credits_ans  :integer          default(0)
#  activated        :boolean          default(FALSE)
#  created_at       :datetime
#  updated_at       :datetime
#  activation_token :string(255)
#
class ActiveRecord::Base
  def self.generate_unique_token_for_field(field)
    begin
      token = SecureRandom.base64(16)
    end until !self.exists?(field => token)

    token
  end
end

class User < ActiveRecord::Base
  before_validation { |user| user.reset_session_token!(false) }

  validates(:password_digest,
            :session_token,
            :email,
            :presence => true
            )

  before_create :set_activation_token

  validates(:email, :uniqueness => true)

  has_many :sent_messages,
   class_name: "Message",
   foreign_key: :sent_by_id,
   inverse_of: :sent_by

  has_many :received_messages,
   class_name: "Message",
   foreign_key: :sent_to_id,
   inverse_of: :sent_to

  has_many :notifications,
    class_name: "Notification",
    foreign_key: :sent_to_id,
    inverse_of: :sent_to

  has_many :user_followers_join,
   class_name: "Following",
   as: :followable

  has_many :user_followers,
   through: :user_followers_join,
   source: :follower

  has_many :followings_join,
   class_name: "Following",
   foreign_key: :f_id

  has_many :users_followed,
    through: :followings_join,
    source: :followable,
    source_type: "User"

  has_many :questions_followed,
    through: :followings_join,
    source: :followable,
    source_type: "Question"


  has_many :topics_followed,
    through: :followings_join,
    source: :followable,
    source_type: "Topic"

  has_many :questions_created,
    class_name: "Question",
    foreign_key: :author_id

  has_many :answers_created,
    class_name: "Answer",
    foreign_key: :author_id

  has_many :topics_created,
    class_name: "Topic",
    foreign_key: :author_id
  # Add upvoted Q/A of friends as well
  has_many :feed_up_followers_questions,
    through: :users_followed,
    source: :questions_upvoted,
    order: "upvoted_join.created_at DESC",
    limit: 5 

  has_many :feed_up_followers_answers,
    through: :users_followed,
    source: :answers_upvoted
    # created by followed
  has_many :feed_followers_questions,
    through: :users_followed,
    source: :questions_created

  has_many :feed_followers_answers,
      through: :users_followed,
      source: :answers_created

  # Questions in topics
  has_many :feed_topics_questions,
    through: :topics_followed,
    source: :questions

  has_many :feed_followedques_answers,
    through: :questions_followed,
    source: :answers

  has_many :upvoted_join,
    class_name: "Upvote",
    foreign_key: :user_id

  has_many :questions_upvoted,
    through: :upvoted_join,
    source: :upvoteable,
    source_type: "Question"

  has_many :answers_upvoted,
    through: :upvoted_join,
    source: :upvoteable,
    source_type: "Answer"

  # followers of followers
  has_many :followed_of_followed_users,
    through: :users_followed,
    source: :users_followed

  has_many :recent_upvote_joins,
  class_name: "Upvote",
  foreign_key: :user_id

  attr_accessor :time_for_feed, :time_for_profile, :time_for_weights, :cache_time_taken

  def feed_objects(last_an_time, last_qn_time)
    # Add questions followed by followed users?

    topics_weightage = self.weightage_topic()
    # debugger
    feed_st_time = Time.now
    feed_scores = Hash.new(){0}
    num_results = 10

    last_an_time ="3000" if last_an_time == "0"
    last_qn_time = "3000" if last_qn_time == "0"
    followed_user_ids = Following.where(f_id: self.id, followable_type: "User").pluck(:followable_id)
    followed_topic_ids = Following.where(f_id: self.id, followable_type: "Topic").pluck(:followable_id)
    feed_questions = Question.find_by_sql ["SELECT qn_list.id AS id,
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
    ActiveRecord::Associations::Preloader.new(feed_questions, :topics).run
    # ActiveRecord::Associations::Preloader.new.preload(feed_questions, :topics)

              # .includes(:topics) to feed_questions may save N+1 queries!
              #Change syntax for PostGRESQL LIMIT 20 OFFSET 10, SQLite: LIMIT 10, 20
    
    feed_answers = Answer.find_by_sql ["SELECT an_list.id AS id,
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
    ActiveRecord::Associations::Preloader.new(feed_answers, question: :topics).run
    # ActiveRecord::Associations::Preloader.new.preload(feed_answers, question: :topics)
     #  ,
    # time_getting_feed = Time.now
    last_an_time = feed_answers.last.sort_time if (feed_answers.length > 0)
    last_qn_time = feed_questions.last.sort_time if (feed_questions.length > 0)
    feed_questions.each do |question|
      question.topics.each do |topic|
        feed_scores[question] += topics_weightage[topic.id] || 1
      end
      feed_scores[question] += question.upvotes
    end
    
    feed_answers.each do |answer|
      answer.question.topics.each do |topic|
        feed_scores[answer] += topics_weightage[topic.id] || 1
      end
      feed_scores[answer] += answer.upvotes
    end

    sorted_feed_results = feed_scores.sort_by{|key, value| value}.map(&:first).reverse
    feed_end_time = Time.now
    feed_time = (feed_end_time - feed_st_time) * 1000
        
    sorted_feed_results = Question.all.sample(num_results) if sorted_feed_results.length == 0

    return sorted_feed_results, last_an_time, last_qn_time
  end

  def weightage_topic
    time_getting_weights = Time.now
    num_topics = Topic.last.id + 1
    cached_topics_weightage = Rails.cache.fetch("topics_weightage_#{self.id}", expires_in: 2.hours) do
      topics_weightage = Array.new(num_topics){1}
      self.questions_followed.each do |question_followed|
        question_followed.topics.each do |topic|
          # topics_weightage[topic.id] ||= 0
          topics_weightage[topic.id] += 5
        end
      end

      self.answers_upvoted.each do |answer_upvoted|
        answer_upvoted.question.topics.each do |topic|
          # topics_weightage[topic.id] ||= 0

          topics_weightage[topic.id] += 5
        end
      end

      self.questions_upvoted.each do |question_upvoted|
        question_upvoted.topics.each do |topic|
          # topics_weightage[topic.id] ||= 0
          topics_weightage[topic.id] += 5
        end
      end

      self.topics_followed.each do |topic|
          # topics_weightage[topic.id] ||= 0
          topics_weightage[topic.id] += 5
      end

      topics_weightage
    end
    time_got_weights = Time.now
    self.time_for_weights = (time_getting_weights - time_got_weights) * 1000
    
    return cached_topics_weightage
  end

  def profile_view(last_obj_sort_time)
    time_getting_profile = Time.now

    #Change so that objects are sorted by the time at which an object was followed/upvoted rather
    #than created at
    num_results = 10
    # Add time constraint on fetched associations?
    # debugger
    
    Rails.cache.delete("profile_view_#{self.id}") if last_obj_sort_time == "0"
    time1 = Time.now
    cached_objects = Rails.cache.fetch("profile_view_#{self.id}", expires_in: 2.hours) do
      profile_questions = Question.find_by_sql ["SELECT qn_list.id AS id,
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
                ORDER BY max(sort_time_c) DESC", {profile_user_id: [self.id]} ]

      profile_answers = Answer.find_by_sql ["SELECT an_list.id AS id,
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
                     WHERE (upvotes.user_id IN (:profile_user_id)) 
                   UNION
                   SELECT answers.*, answers.created_at AS sort_time_c
                      FROM answers 
                      WHERE (answers.author_id IN (:profile_user_id)))  AS an_list
                   GROUP BY an_list.id
                   ORDER BY max(sort_time_c) DESC",  {profile_user_id:  [self.id]} ]

      all_objects = (profile_questions + profile_answers).sort{|obj1, obj2| (obj2.sort_time <=> obj1.sort_time)}  
      all_objects
    end
    time2= Time.now
    time_taken = time2 - time1
    if last_obj_sort_time == "0"
      return cached_objects[0, num_results]
    else
      last_obj_index = cached_objects.find_index{|obj| obj.sort_time == last_obj_sort_time}
      return cached_objects[last_obj_index + 1 , num_results]
    end
    # last_obj_created = cached_objects.select{|cached_obj| cached_obj.}
    # show_objects = all_objects.slice(start_index,end_index)
    # time_got_profile = Time.now

    # self.time_for_profile = (time_getting_profile - time_got_profile)*1000
    # debugger
    # return show_objects
    # followed questions and topics
    # upvoted questions and answers
    # for each question/answer/topic upvoted /followed, add 5 to weight of all topics concerning the Q/A/T. - > provides weight for each topic
  end

  def self.search(keywords)
    all_topics = Topic.all
    all_questions = Question.all
    all_users = User.all
    num_results = 10

    keywords_array = keywords.chomp.split(" ").map(&:downcase)
    search_scores = Hash.new(){0}

    return_objects = {}
    all_topics.each do |topic|
      topic_array = topic.title.split(" ").map(&:downcase)
      keywords_included = keywords_array.select{|keyword| topic_array.include?(keyword)}
      keywords_included.each{|keyword| search_scores[topic] += (keyword.length**2)}
    end

    all_questions.each do |question|
      question_array = question.main_question.split(/[\s,?]/).map(&:downcase)
      keywords_included = keywords_array.select{|keyword| question_array.include?(keyword)}
      keywords_included.each{|keyword| search_scores[question] += (keyword.length**2)}
    end

    all_users.each do |user_a|
      user_array = user_a.name.split(" ").map(&:downcase)
      keywords_included = keywords_array.select{|keyword| user_array.include?(keyword)}
      keywords_included.each{|keyword| search_scores[user_a] += (keyword.length**2)}
    end

    results = []
    search_scores.each do |key, value|
      if (results.length < num_results || results.last.values.last < value)
        results.pop if results.length >= num_results
        results.push({key => value})
        results = User.array_sort(results)
      end
    end

    results.map!{|obj| obj.keys.first}

    return results
  end
  # Make join table with scores?
  def rec_users_to_follow(num_scrolls)
    cache_st_time = Time.now

    Rails.cache.delete("fof_sorted_scores_#{self.id}") if num_scrolls == 0
    cached_sorted_rec_users = Rails.cache.fetch("fof_sorted_scores_#{self.id}", expires_in: 5.hours) do
      followed_users = self.users_followed
      topics_followed = self.topics_followed
      questions_followed = self.questions_followed
      num_results = 5
      fof_scores = Hash.new(){0}
      followed_users.each do |followed_user|
        followed_user.users_followed.each do |fof_user|
          if (!followed_users.include?(fof_user))
            if (!fof_scores[fof_user])
              fof_user.topics_followed.each do |topic_followed|
                fof_scores[fof_user] += 1 if topics_followed.include?(topic_followed) #Make sure this works
              end
              fof_user.questions_followed.each do |question_followed|
                fof_scores[fof_user] += 1 if questions_followed.include?(question_followed) #Make sure this works
              end
            end
            fof_scores[fof_user] += 3
          end
        end
      end
      sorted_rec_users = fof_scores.sort_by{|key, value| value}.map(&:first).reverse
    end
    cache_end_time = Time.now
    self.cache_time_taken = cache_end_time - cache_st_time 
    return cached_sorted_rec_users[num_scrolls*5, 5]
  end


  def show_qns_created(last_qn_created_at)
    num_results = 10
    # debugger
    Rails.cache.delete("qns_created_#{self.id}") if last_qn_created_at == "0"
    time1 = Time.now
    cached_questions = Rails.cache.fetch("qns_created_#{self.id}", expires_in: 2.hours) do
      questions_created = Question.find_by_sql ["
                SELECT questions.*, questions.created_at AS sort_time
                FROM questions 
                WHERE (questions.author_id = :profile_user_id) 
                ORDER BY sort_time DESC", {profile_user_id: self.id} ]      
    end   

    if last_qn_created_at == "0"
      return cached_questions[0, num_results]
    else
      last_qn_index = cached_questions.find_index{|qn| qn.created_at == last_qn_created_at}
      return cached_questions[last_qn_index + 1 , num_results]
    end

  end

  def show_ans_created(last_an_created_at)
    num_results = 10
    # debugger
    Rails.cache.delete("ans_created_#{self.id}") if last_an_created_at == "0"
    
    cached_answers = Rails.cache.fetch("ans_created_#{self.id}", expires_in: 2.hours) do
      answers_created = Answer.find_by_sql ["
                SELECT answers.*, answers.created_at AS sort_time
                FROM answers 
                WHERE (answers.author_id = :profile_user_id) 
                ORDER BY sort_time DESC", {profile_user_id: self.id} ]      
    end   

    if last_an_created_at == "0"
      return cached_answers[0, num_results]
    else
      last_an_index = cached_answers.find_index{|an| an.created_at == last_an_created_at}
      return cached_answers[last_an_index + 1 , num_results]
    end

  end

  def followers_fn(last_follower_created_at)
    num_results = 10
    # debugger
    Rails.cache.delete("followers_created_#{self.id}") if last_follower_created_at == "0"
    time1 = Time.now
    cached_followers = Rails.cache.fetch("followers_created_#{self.id}", expires_in: 2.hours) do
      followers_created = User.find_by_sql ["
                SELECT users.*, followings.created_at AS sort_time
                FROM users
                INNER JOIN followings
                ON users.id = followings.f_id AND followings.followable_type = 'User' 
                WHERE (followings.followable_id = :profile_user_id) 
                ORDER BY sort_time DESC", {profile_user_id: self.id} ]      
    end   

    if last_follower_created_at == "0"
      return cached_followers[0, num_results]
    else
      last_follower_index = cached_followers.find_index{|follower| follower.created_at == last_follower_created_at}

      return cached_followers[last_follower_index + 1 , num_results]
    end

  end

  def followed_users_fn(last_fu_created_at)
    num_results = 10
    # debugger
    Rails.cache.delete("fu_created_#{self.id}") if last_fu_created_at == "0"
    cached_followed_users = Rails.cache.fetch("fu_created_#{self.id}", expires_in: 2.hours) do
      followed_users = User.find_by_sql ["
                SELECT users.*, followings.created_at AS sort_time
                FROM users
                INNER JOIN followings
                ON users.id = followings.followable_id AND followings.followable_type = 'User' 
                WHERE (followings.f_id = :profile_user_id) 
                ORDER BY sort_time DESC", {profile_user_id: self.id} ]    
    end   

    if last_fu_created_at == "0"
      return cached_followed_users[0, num_results]
    else
      last_fu_index = cached_followed_users.find_index{|fu| fu.created_at == last_fu_created_at}
      return cached_followed_users[last_fu_index + 1 , num_results]
    end

  end
  
  def self.array_sort(array_results)
    return array_results.sort!{|result1, result2| result2.values.first <=> result1.values.first}
  end

  def self.generate_session_token
    self.generate_unique_token_for_field(:session_token)
  end

  def self.find_by_credentials(email, secret)
    user = User.find_by_email(email)

    user.is_password?(secret) ? user : nil
  end

  def set_activation_token
    self.activation_token = self.class.generate_unique_token_for_field(:activation_token)
  end

  def password=(secret)
    @password = secret
    self.password_digest = BCrypt::Password.create(secret).to_s
  end

  def is_password?(secret)
    BCrypt::Password.new(self.password_digest).is_password?(secret)
  end

  def reset_session_token!(force = true)
    return unless self.session_token.nil? || force

    self.session_token = User.generate_session_token
    self.save!
  end

  def activate!
    self.update_attribute(:activated, true)
  end
end
