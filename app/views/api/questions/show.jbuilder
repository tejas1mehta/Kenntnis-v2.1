json.partial! 'api/shared/extract_all', object: @question

json.author @question.author
json.topics_join  @question.topics_join do |topic_join|
  json.partial! 'api/shared/extract_all', object: topic_join
  json.topic topic_join.topic
end
json.comments @question.comments, :comment_body, :author, :upvotes, :parent_comment_id
json.upvotes_join @question.upvotes_join
json.followers_join @question.followers_join

json.answers @question.answers do |answer|
  json.partial! 'api/shared/extract_all', object: answer
  json.author answer.author
  json.upvotes_join answer.upvotes_join
end

json.relevant_user_joins @question.relevant_user_joins do |rel_user_join|
  json.partial! 'api/shared/extract_all', object: rel_user_join
  json.relevant_user rel_user_join.relevant_user
end
