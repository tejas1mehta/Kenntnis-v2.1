json.partial! 'api/shared/extract_all', object: @topic

json.author @topic.author
json.followers_join @topic.followers_join

json.questions_join  @topic.questions_join.includes(:question => [:author, :upvotes_join, :followers_join]) do |question_join|
  json.partial! 'api/shared/extract_all', object: question_join
  json.question do 
    json.partial! 'api/shared/extract_all', object: question_join.question
	  json.author question_join.question.author
	  json.upvotes_join question_join.question.upvotes_join
	  json.followers_join question_join.question.followers_join
  end
end
