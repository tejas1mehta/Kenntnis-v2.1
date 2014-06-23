json.partial! 'api/shared/extract_all', object: @user

json.followings_join @user.followings_join.includes(:followable) do |following_join|
  json.partial! 'api/shared/extract_all', object: following_join
  json.followable following_join.followable
end



