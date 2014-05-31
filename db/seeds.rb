#encoding: utf-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'faker'
# f = File.open("my/file/path", "r")
my_questions = File.readlines('db/Questions.txt')
num_questions = my_questions.length
num_users = 10
num_topics = 10
num_answers = 3* num_questions

# Users
9.times do |index|
  faker_name = Faker::Name.name + "index"
  faker_email = Faker::Internet.email #=> "christelle@example.org"
  faker_location = Faker::Address.city
  faker_employment = Faker::Company.name
  faker_about = Faker::Lorem.sentence(10)
  # fake_password = Faker::N
  users = User.create([{email:faker_email,name:faker_name,password:"qwerty",activated: true,location: faker_location,
   employment: faker_employment, about: faker_about}])
end

User.create([{email:"guest@knowledge.com",name:"Guest",password:"qwerty",activated: true,location: "USA"}])

# Questions
user_id = 0
my_questions.each_with_index do |question, index|
  if (user_id % (num_users) == 0 )
    user_id = 0
  end
  user_id += 1
  faker_descr = Faker::Lorem.sentence(10)

  questions = Question.create([{main_question: question.chomp, description: faker_descr, author_id: user_id}])
end

# Answers
user_id = 0
question_id = num_questions

(num_answers).times do |index|
  if (index % (num_users) == 0 )
    user_id = 0
  end
  user_id += 1
  if (question_id == 0)
    question_id = num_questions
  end
  faker_answer = Faker::Lorem.sentence(10)

  answer = Answer.create({author_id: user_id, question_id: question_id, main_answer: faker_answer})
  question_id -=1
end

# Topics
user_id = 0
num_topics.times do |index|
  if (user_id % (num_users) == 0 )
    user_id = 0
  end
  user_id += 1
  faker_topic = Faker::Commerce.department
  topic = Topic.create({title: faker_topic, author_id: user_id})
end

# User Followings
user_id = 0
followed_id = 0
(num_users).times do |index|
  user_id += 1
  4.times do
    if (followed_id == num_users)
      followed_id = 0
    end
    followed_id +=1
    followings = Following.create([{f_id: user_id, followable_type: "User", followable_id: followed_id}])
  end
end



#QuestionFollowings and Votes
user_voting_id = 0
user_following_id = num_users
question_id = 0
(num_questions).times do |index|
  question_id += 1
  4.times do
    if (user_voting_id % (num_users) == 0 )
      user_voting_id = 0
    end
    user_voting_id += 1
    if (user_following_id == 0)
      user_following_id = num_users
    end
    # p "voted_id: #{voted_id}, followed_id: #{followed_id}, user_id: #{user_id}"
    Following.create([{f_id: user_following_id, followable_type: "Question", followable_id: question_id}])
    Upvote.create([{user_id: user_voting_id, upvoteable_type: "Question", upvoteable_id: question_id}])

    user_following_id -= 1
  end
end


#Answer Votes
user_id = 0
voted_id = 0
(num_answers).times do |index|
  voted_id +=1
  5.times do
    if (user_id % (num_users) == 0 )
      user_id = 0
    end
    user_id += 1
    upvotes = Upvote.create([{user_id: user_id, upvoteable_type: "Answer", upvoteable_id: voted_id}])
  end
end

# Questions - Topics
question_id = 0
topic_id = 0
(num_questions).times do |index|
  question_id += 1
  3.times do
    if (topic_id % (num_topics) == 0)
      topic_id = 0
    end
    topic_id += 1
    TopicQuestionJoin.create([{question_id: question_id, topic_id: topic_id}])
  end
end

#Topic Followings

user_following_id = num_users
topic_id = 0
(num_topics).times do |index|
  topic_id += 1
  4.times do
    if (user_following_id == 0)
      user_following_id = num_users
    end
    # p "voted_id: #{voted_id}, followed_id: #{followed_id}, user_id: #{user_id}"
    Following.create([{f_id: user_following_id, followable_type: "Topic", followable_id: topic_id}])
    user_following_id -= 1
  end
end


# followings = Following.create([{f_id: 1, followable_type: "User", followable_id: 2},
#   {f_id: 1, followable_type: "Question", followable_id: 2},
#   {f_id: 1, followable_type: "Question", followable_id: 1},
#   {f_id: 1, followable_type: "Topic", followable_id: 1}
#   ])

# answers = Answer.create([
#   {question_id: 1, main_answer: "It is a machine that does work.", author_id: 1},
#   {question_id: 1, main_answer: "It is a machine that does more work.", author_id: 1},
# ])

# upvotes = Upvote.create([
#   { user_id: 1, upvoteable_id: 1, upvoteable_type: "Question"},
#   { user_id: 1, upvoteable_id: 2, upvoteable_type: "Question"},
#   { user_id: 2, upvoteable_id: 1, upvoteable_type: "Question"}
# ])

# messages = Message.create([
#   {message_body: "Hi, whats up?", sent_by_id: 1, sent_to_id: 2, subject:"Hello"},
#   {message_body: "Hi, hows it going?", sent_by_id: 2, sent_to_id: 1, subject:"Hey"},
# ])
