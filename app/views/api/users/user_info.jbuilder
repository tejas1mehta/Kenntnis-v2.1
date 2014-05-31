json.partial! 'api/shared/extract_all', object: @user

json.followings_join @user.followings_join do |following_join|
  json.partial! 'api/shared/extract_all', object: following_join
  json.followable following_join.followable
end

json.upvoted_join @user.upvoted_join do |upvote_join|
  json.partial! 'api/shared/extract_all', object: upvote_join
end
