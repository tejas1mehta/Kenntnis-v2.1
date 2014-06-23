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
# my_questions = File.readlines('db/Questions.txt')
# num_questions = my_questions.length
num_users = 25
topics = ["Programming", "Computer Science", "Security", "Technology", "Science", "Math", "Fiction", "Physics", "Movies", "Television"]
num_topics = topics.length
# num_answers = 3* num_questions

# Users
(num_users - 1).times do |index|
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

# Topics
user_id = 0
num_topics.times do |index|
  if (user_id % (num_users) == 0 )
    user_id = 0
  end
  user_id += 1
  topic = Topic.create({title: topics[index], author_id: user_id})
end



# Questions
def create_qn_ans(question_doc, num_users)
  questions_array = question_doc.split("QuestionKenntnis:")[1..-1]
  user_id = 0
  ans_user_id = 0
  questions_array.each_with_index do |full_question, index|
    if (user_id % (num_users) == 0 )
      user_id = 0
    end
    user_id += 1
    full_question_split = full_question.split("qn_description:")
    main_question_txt = full_question_split.shift
    question_split = full_question_split.first.split("AnswersKenntnis")
    qn_description = question_split.shift
    question_obj = Question.create({main_question: main_question_txt, description: qn_description, author_id: user_id})
    answers = question_split.first.split("AnswerKenntnis")
    answers.shift
    answers.each_with_index do |answer,ans_index|
      if (ans_index % (num_users) == 0 )
        ans_user_id = 0
      end
      ans_user_id += 1
      Answer.create({author_id: ans_user_id, question_id: question_obj.id, main_answer: answer})
    end
  end
end
create_qn_ans(File.read('db/question.txt'), num_users)
create_qn_ans(File.read('db/question_programmers.txt'), num_users)
create_qn_ans(File.read('db/question_security.txt'), num_users)
create_qn_ans(File.read('db/question_math.txt'), num_users)
create_qn_ans(File.read('db/question_physics.txt'), num_users)
create_qn_ans(File.read('db/question_scifi.txt'), num_users)
create_qn_ans(File.read('db/question_movies.txt'), num_users)
num_questions = Question.all.length
num_answers = Answer.all.length
# Questions - Topics
topics = ["Programming", "Computer Science", "Security", "Technology", "Science", "Math", "Fiction", "Physics",
 "Movies", "Television"]
topics_to_add = [[1, 3],[1, 0],[0, 1, 2],
[5, 4], [5, 4, 7], [6,4, 3],[8]]
question_id = 1
7.times do |topic_sel|
  (50).times do |index|
    topics_to_add[topic_sel].each do |topic_id|
      TopicQuestionJoin.create({question_id: question_id, topic_id: (topic_id + 1)})
    end
    question_id += 1
  end
end


# User Followings
user_id = 0
followed_id = 0
(num_users).times do |index|
  user_id += 1
  num_folls = rand((2..6))
  num_folls.times do
    if (followed_id == num_users)
      followed_id = 0
    end
    followed_id +=1
    followings = Following.create([{f_id: user_id, followable_type: "User", followable_id: followed_id}])
  end
end

Following.create([{f_id: 7, followable_type: "Question", followable_id: 7}])


#QuestionFollowings and Votes
user_voting_id = 0
user_following_id = num_users
question_id = 0
(num_questions).times do |index|
  question_id += 1
  rand((2..6)).times do
    if (user_voting_id % (num_users) == 0 )
      user_voting_id = 0
    end
    user_voting_id += 1
    if (user_following_id == 0)
      user_following_id = num_users
    end
    # p "voted_id: #{voted_id}, followed_id: #{followed_id}, user_id: #{user_id}"
    Upvote.create([{user_id: user_voting_id, upvoteable_type: "Question", upvoteable_id: question_id}])

    user_following_id -= 1
  end
end

user_voting_id = 0
user_following_id = num_users
question_id = 0
(num_questions).times do |index|
  question_id += 1
  rand((2..6)).times do
    if (user_voting_id % (num_users) == 0 )
      user_voting_id = 0
    end
    user_voting_id += 1
    if (user_following_id == 0)
      user_following_id = num_users
    end
    # p "voted_id: #{voted_id}, followed_id: #{followed_id}, user_id: #{user_id}"
    Following.create([{f_id: user_following_id, followable_type: "Question", followable_id: question_id}])

    user_following_id -= 1
  end
end

Upvote.create([{user_id: 7, upvoteable_type: "Question", upvoteable_id: 39}])

#Answer Votes
user_id = 0
voted_id = 0
(num_answers).times do |index|
  voted_id +=1
  rand((2..6)).times do
    if (user_id % (num_users) == 0 )
      user_id = 0
    end
    user_id += 1
    upvotes = Upvote.create([{user_id: user_id, upvoteable_type: "Answer", upvoteable_id: voted_id}])
  end
end



#Topic Followings

user_following_id = num_users
topic_id = 0
(num_topics).times do |index|
  topic_id += 1
  rand((2..6)).times do
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
