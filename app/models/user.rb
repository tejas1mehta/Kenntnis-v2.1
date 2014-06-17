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
  
  def sorted_time_str
    return self.sort_time.strftime("%d/%m/%Y %H:%M:%S:%L")
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

  # has_many :recent_upvote_joins,
  # class_name: "Upvote",
  # foreign_key: :user_id

  attr_accessor :time_for_feed, :time_for_profile, :time_for_weights, :cache_time_taken

  def feed_objects(last_an_time, last_qn_time)
    num_results = 15

    last_an_time =Time.now if last_an_time == "0"
    last_qn_time = Time.now if last_qn_time == "0"
 
    feed_questions = Question.get_feed_qns(self.users_followed_ids, self.topics_followed_ids, last_qn_time)
    ActiveRecord::Associations::Preloader.new(feed_questions, [:topics, :author, :upvotes_join, :followers_join]).run
    
    feed_answers = Answer.get_feed_ans(self.users_followed_ids, last_an_time) 
    ActiveRecord::Associations::Preloader.new(feed_answers, [:author, :upvotes_join,
         :question => [:author, :upvotes_join, :followers_join, :topics]]).run

    last_an_time = feed_answers.last.sort_time if (feed_answers.length > 0)
    last_qn_time = feed_questions.last.sort_time if (feed_questions.length > 0)
    
    sorted_feed_results = sort_feed_results(feed_answers, feed_questions)
    sorted_feed_results = Question.all.sample(num_results) if sorted_feed_results.length == 0

    return sorted_feed_results, last_an_time, last_qn_time
  end

  def sort_feed_results(feed_answers, feed_questions)
    topics_weightage = self.weightage_topic()
    feed_scores = Hash.new(){0}

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
    return sorted_feed_results
  end

  def weightage_topic
    num_topics = Topic.last.id + 1
    cached_topics_weightage = Rails.cache.fetch("topics_weightage_#{self.id}", expires_in: 2.hours) do
      topics_weightage = Array.new(num_topics){1}
      qns = self.questions_followed.select("questions.id, topics.id AS topic_id").joins(:topics)
      qns.each do |question_followed|
          topics_weightage[question_followed.topic_id] += 5
      end

      ans_topics = self.answers_upvoted.includes(:question => :topics)

      ans_topics.each do |answer_upvoted|
        answer_upvoted.question.topics.each do |topic|
          topics_weightage[topic.id] += 5
        end
      end

      qns = self.questions_upvoted.select("questions.id, topics.id AS topic_id").joins(:topics)
      qns.each do |question_upvoted|
          topics_weightage[question_upvoted.topic_id] += 5
      end

      self.topics_followed.each do |topic|
          topics_weightage[topic.id] += 5
      end

      topics_weightage
    end
    
    return cached_topics_weightage
  end
  
  def preload_qns_ans(objs_array)
    qns_array = []
    ans_array = []
    objs_array.each do |object|
      if object.class == Answer
        ans_array.push(object)
      elsif object.class == Question
        qns_array.push(object)
      end
    end
    ActiveRecord::Associations::Preloader.new(qns_array, [:author, :upvotes_join, :followers_join]).run
    ActiveRecord::Associations::Preloader.new(ans_array, [:author, :upvotes_join,
         :question => [:author, :upvotes_join, :followers_join]]).run
  end

  def profile_view(last_obj_sort_time)
    time_getting_profile = Time.now
    num_results = 10

    Rails.cache.delete("profile_view_#{self.id}") if last_obj_sort_time == "0"
    cached_objects = Rails.cache.fetch("profile_view_#{self.id}", expires_in: 2.hours) do
      profile_questions = Question.get_profile_qns(self.id)
      profile_answers = Answer.get_ans([self.id], Time.now) 
      all_objects = (profile_questions + profile_answers).sort{|obj1, obj2| (obj2.sort_time <=> obj1.sort_time)}  
      all_objects
    end
    
    if last_obj_sort_time == "0"
      profile_objs = cached_objects[0, num_results]
    else
      last_obj_index = cached_objects.find_index{|obj| obj.sorted_time_str == last_obj_sort_time}
      profile_objs = cached_objects[last_obj_index + 1 , num_results]
    end
    preload_qns_ans(profile_objs)
    return profile_objs
  end

  # searchable do
  #   text :email , boost: 2.0
  #   text :name, boost: 3.0
  #   text :location
  #   text :education
  #   text :employment
  # end

  def self.search1(keywords)
    # @search = Sunspot.search(User, Topic, Question, Answer) do
    #   keywords keywords_entered
    # end

    # debugger
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
    num_results = 3
    Rails.cache.delete("fof_sorted_scores_#{self.id}") if num_scrolls == 0
    
    cached_sorted_rec_users = Rails.cache.fetch("fof_sorted_scores_#{self.id}", expires_in: 5.hours) do
      followed_users = self.users_followed.includes(:users_followed)
      fof_scores = Hash.new(){0}
      followed_users.each do |followed_user|
        followed_user.users_followed.each do |fof_user|
            fof_scores[fof_user] += 3 if (!followed_users.include?(fof_user))          
        end
      end      
      sorted_rec_users = fof_scores.sort_by{|key, value| value}.map(&:first).reverse
    end

    return cached_sorted_rec_users[num_scrolls*num_results, num_results]
  end

  def return_objects(last_obj_created_at, cached_objs)
    num_results = 10
    if last_obj_created_at == "0"
      user_objs = cached_objs.limit(10)
    else
      last_obj_index = cached_objs.find_index{|obj| obj.sorted_time_str == last_obj_created_at}
      user_objs = cached_objs.limit(10).offset(last_obj_index + 1)
    end
    return user_objs
  end

  def show_qns_created(last_qn_created_at)
    Rails.cache.delete("qns_created_#{self.id}") if last_qn_created_at == "0"
    cached_questions = Rails.cache.fetch("qns_created_#{self.id}", expires_in: 2.hours) do
      questions_created = self.questions_created.select("questions.*, questions.created_at AS sort_time").
      order("created_at DESC")   
    end   
    user_qns = return_objects(last_qn_created_at,cached_questions)

    ActiveRecord::Associations::Preloader.new(user_qns, [:author, :upvotes_join, :followers_join]).run
    return user_qns
  end
  
  def show_ans_created(last_an_created_at)
    Rails.cache.delete("ans_created_#{self.id}") if last_an_created_at == "0"
    
    cached_answers = Rails.cache.fetch("ans_created_#{self.id}", expires_in: 2.hours) do
      answers_created = self.answers_created.select("answers.*, answers.created_at AS sort_time").
      order("created_at DESC")   
    end   
    user_ans = return_objects(last_an_created_at, cached_answers)
    ActiveRecord::Associations::Preloader.new(user_ans, [:author, :upvotes_join,
     :question => [:author, :upvotes_join, :followers_join]]).run

    return user_ans
  end

  def return_users(last_obj_created_at, cached_objs)
    num_results = 10
    if last_obj_created_at == "0"
      user_objs = cached_objs[0,10]
    else
      last_obj_index = cached_objs.find_index{|obj| obj.sorted_time_str == last_obj_created_at}
      user_objs = cached_objs[last_obj_index + 1, 10]
    end
    return user_objs
  end

  def followers_fn(last_follower_created_at)
    num_results = 10
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
    user_folls = return_users(last_follower_created_at, cached_followers)

    ActiveRecord::Associations::Preloader.new(user_folls,:user_followers_join).run

    return user_folls
  end

  def followed_users_fn(last_fu_created_at)
    num_results = 10
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

    followed_users = return_users(last_fu_created_at, cached_followed_users)
    ActiveRecord::Associations::Preloader.new(followed_users,:user_followers_join).run

    return followed_users
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