class ChangeNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :notification_kind, :string
  end
end
