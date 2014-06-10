json.partial! 'api/shared/extract_all', object: @user

json.results @results do |result|
  json.partial! 'api/shared/extract_all', object: result
  json.author result.author
  json.upvotes_join result.upvotes_join

  json.resultclass result.class.to_s
  if (result.class.to_s == "Answer")
    json.question do
      json.partial! 'api/shared/extract_all', object: result.question
      json.author result.question.author
      json.upvotes_join result.question.upvotes_join
      json.followers_join result.question.followers_join
    end
  else
      json.followers_join result.followers_join
  end

end

json.user_followers_join @user.user_followers_join

json.last_obj_time @results.last.sort_time.strftime("%d/%m/%Y %H:%M:%S:%L") if (@results.length > 0)

# json.(@user, :email, :name, :about, :location, :education, :employment, :credits)
#
# json.questions_created @user.questions_created do |question_created|
#   json.partial! 'api/shared/extract_all', object: question_created
#   json.author question_created.author
# end
#
# json.answers_created @user.answers_created do |answer_created|
#   json.partial! 'api/shared/extract_all', object: answer_created
#   json.upvotes answer_created.upvotes
#   json.author answer_created.author
#   json.question answer_created.question
#   json.created_at answer_created.created_at
# end
#
# # Modify to be like answers_created with author name
# json.questions_followed @user.questions_followed do |question_followed|
#  json.main_question question_followed.main_question
#  json.upvotes question_followed.upvotes
#  json.author question_followed.author
#  json.id question_followed.id
#  json.following Following.find_by({f_id: @user.id, followable_id: question_followed.id, followable_type:"Question"})
# end
#
# json.topics_followed @user.topics_followed do |topic_followed|
#  json.partial! 'api/shared/extract_all', object: topic_followed
#  json.author topic_followed.author
#  json.following Following.find_by({f_id: @user.id, followable_id: topic_followed.id, followable_type:"Topic"})
# end
#
#
# json.users_followed @user.users_followed
# json.users_following @user.user_followers
# json.answers_upvoted @user.answers_upvoted do |answer_upvoted|
#   json.partial! 'api/shared/extract_all', object: answer_upvoted
#   json.author answer_upvoted.author
#   json.question answer_upvoted.question
#   json.upvote Upvote.find_by({user_id: @user.id, upvoteable_id: answer_upvoted.id, upvoteable_type:"Answer"})
# end
#
# json.questions_upvoted @user.questions_upvoted do |question_upvoted|
#   json.partial! 'api/shared/extract_all', object: question_upvoted
#   json.author question_upvoted.author
#   json.upvote Upvote.find_by({user_id: @user.id, upvoteable_id: question_upvoted.id, upvoteable_type:"Question"})
# end
#
# json.user_show_type "userprofile"