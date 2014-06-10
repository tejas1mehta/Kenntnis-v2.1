json.partial! 'api/shared/extract_all', object: @topic

json.author @topic.author
json.followers_join @topic.followers_join


json.questions @topic.questions do |question|
  json.partial! 'api/shared/extract_all', object: question
  json.author question.author
  json.upvotes_join question.upvotes_join
  json.followers_join question.followers_join
end
