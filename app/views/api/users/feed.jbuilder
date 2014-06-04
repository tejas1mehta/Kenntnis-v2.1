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

json.last_an_time @last_an_time 

json.last_qn_time @last_qn_time

json.rec_users @rec_users do |rec_user|
  json.partial! 'api/shared/extract_all', object: rec_user
  json.user_followers_join rec_user.user_followers_join
end

