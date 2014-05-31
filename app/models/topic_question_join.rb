class TopicQuestionJoin < ActiveRecord::Base
  validates :question, :topic_id, presence: true

  belongs_to :question, inverse_of: :topics_join

  belongs_to :topic

end
