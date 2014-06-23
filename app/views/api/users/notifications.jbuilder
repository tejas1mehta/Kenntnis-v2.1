json.notifications @user_notifications do |notification|
  json.partial! 'api/shared/extract_all', object: notification
  json.sent_by notification.sent_by
  json.about_object do 
    json.partial! 'api/shared/extract_all', object: notification.about_object
    json.resultclass notification.about_object.class.to_s
  end
end