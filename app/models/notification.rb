class Notification < ActiveRecord::Base
  validates :sent_to, presence: true

  belongs_to :sent_to,
    class_name: "User",
    foreign_key: :sent_to_id,
    inverse_of: :notifications

  belongs_to :sent_by,
    class_name: "User",
    foreign_key: :sent_by_id

  belongs_to :about_object, polymorphic: true
  attr_accessor :backbone_id
  def self.get_notifications(user_id, status)
# (n.notification_kind + n.about_object_id + n.about_object_type) AS id,
    new_notifications = Notification.find_by_sql ["SELECT 
        MAX(n.sent_by_id) AS sent_by_id,
        MAX(n.sent_to_id) AS sent_to_id,
        n.about_object_id AS about_object_id,
        n.about_object_type AS about_object_type,
        max(n.created_at) AS created_at,
        n.viewed AS viewed,
        COUNT(*) AS num_users,
        n.notification_kind AS notification_kind
        FROM notifications n
        WHERE (n.sent_to_id = :user_id AND n.viewed IN (:status))
        GROUP BY n.notification_kind, n.about_object_id, n.about_object_type, n.viewed
        ORDER BY max(n.created_at) DESC",{user_id: user_id, status: status}]
    ActiveRecord::Associations::Preloader.new(new_notifications, [:sent_by, :about_object]).run

    new_notifications.each{|n| n.backbone_id =  n.notification_kind + n.about_object_id.to_s + n.about_object_type}

    return new_notifications
  end
end
