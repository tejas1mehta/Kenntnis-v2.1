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

json.last_obj_time @results.last.sorted_time_str if (@results.length > 0)
