class Topic < ActiveRecord::Base
  validates :title, presence: true

  has_many :questions_join, 
    class_name: "TopicQuestionJoin",
    foreign_key: :topic_id

  has_many :questions,
    through: :questions_join,
    source: :question

  has_many :answers,
    through: :questions,
    source: :answers

  has_many :followers_join, class_name: "Following", as: :followable

  has_many :followers,
    through: :followers_join,
    source: :follower



  belongs_to :author,
    class_name: "User",
    foreign_key: :author_id
    # Topic user knowledge table
  def knowledgable_users
    topic_answers = self.answers
    topic_user_scores = Hash.new(){0}
    authors_with_answers = Hash.new(){0}

    topic_answers.each do |answer|
      answer_author = answer.author
      authors_with_answers.push(answer_author)
      topic_user_scores[answer_author] += 1
    end

    authors_with_answers.each do |author|
      prev_record = TopicUserKnow.find_by({author_id: author.id, topic_id: topic.id})
      if prev_record
        prev_record.update_attributes({score: topic_user_scores[author] })
      else
        TopicUserKnow.create({author_id: author.id, topic_id: topic.id, score: topic_user_scores[author]})
      end
    end

  end

end
