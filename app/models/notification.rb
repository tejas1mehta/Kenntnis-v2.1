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
end
