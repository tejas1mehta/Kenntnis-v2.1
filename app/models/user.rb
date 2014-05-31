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
    source: :questions_upvoted


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

  def feed_questions(num_scrolls)
    # Add questions followed by followed users?
    topics_weightage = self.weightage_topic()
    feed_scores = Hash.new(){0}
    num_results = 10
    # Add time constraint on fetched associations?
    # debugger
    # show_fuf_questions = self.feed_up_followers_questions.

    self.feed_up_followers_questions.each do |question|
      question.topics.each do |topic|
        feed_scores[question] += topics_weightage[topic]
      end
    end

    self.feed_up_followers_answers.each do |answer|
      answer.question.topics.each do |topic|
        feed_scores[answer] += topics_weightage[topic]
      end
    end

    self.feed_followers_questions.each do |question|
      question.topics.each do |topic|
        feed_scores[question] += topics_weightage[topic]
      end
    end

    # self.feed_followers_answers.each do |answer|
    #   answer.question.topics.each do |topic|
    #     feed_scores[answer] += topics_weightage[topic]
    #   end
    # end
    #
    # self.feed_topics_questions.each do |question|
    #   question.topics.each do |topic|
    #     feed_scores[question] += topics_weightage[topic]
    #   end
    # end
    #
    # self.feed_followedques_answers.each do |answer|
    #   answer.question.topics.each do |topic|
    #     feed_scores[answer] += topics_weightage[topic]
    #   end
    # end
    results = []
    feed_scores.each do |key, value|
      if (results.length < 100 || results.last.values.last < value)
        results.pop if results.length >= 100
        results.push({key => value})
        results = User.array_sort(results)
      end
    end

    results.map!{|obj| obj.keys.first}
    start_index = num_scrolls*num_results
    end_index = (num_scrolls + 1)*num_results
    results = results[start_index..end_index] || []
    if (results.length < num_results)
      all_questions = Question.all
      results.push(all_questions.sample(num_results)).flatten!
    end

    return results
    # followed questions and topics
    # upvoted questions and answers
    # for each question/answer/topic upvoted /followed, add 5 to weight of all topics concerning the Q/A/T. - > provides weight for each topic
  end

  def weightage_topic
    topics_weightage = Hash.new(){0}
    self.questions_followed.each do |question_followed|
      question_followed.topics.each do |topic|
        topics_weightage[topic] += 5
      end
    end

    # self.answers_upvoted.each do |answer_upvoted|
    #   answer_upvoted.question.topics.each do |topic|
    #     topics_weightage[topic] += 5
    #   end
    # end

    # self.questions_upvoted.each do |question_upvoted|
    #   question_upvoted.topics.each do |topic|
    #     topics_weightage[topic] += 5
    #   end
    # end

    # self.topics_followed.each do |topic_followed|
    #     topics_weightage[topic_followed] += 5
    # end

    return topics_weightage
  end

  def profile_view(num_scrolls)
    #Change so that objects are sorted by the time at which an object was followed/upvoted rather
    #than created at
    num_results = 10
    # Add time constraint on fetched associations?
    # debugger
    show_profile = []
    all_objects = []
    all_objects.push(self.questions_followed).push(self.answers_created).
    push(self.questions_created).push(self.answers_upvoted)
    .push(self.questions_upvoted)

    all_objects.flatten!.uniq!
    all_objects.sort!{|result1, result2| result2.created_at <=> result1.created_at}
    start_index = num_scrolls*num_results
    end_index = (num_scrolls+1)*num_results
    show_objects = all_objects.slice(start_index,end_index)

    return show_objects
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
  def rec_users_to_follow
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


    results = []
    fof_scores.each do |key, value|
      if (results.length < num_results || results.last.values.last < value)
        results.pop if results.length >= num_results
        results.push({key => value})
        results = User.array_sort(results)
      end
    end

    results.map!{|obj| obj.keys.first}

    return results
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
