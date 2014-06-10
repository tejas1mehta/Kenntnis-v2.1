#encoding: utf-8

class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
     	t.text :notification_body
    	t.integer :sent_by_id
    	t.integer :sent_to_id, null: false
      t.references :about_object, polymorphic: true
    	t.boolean :viewed, default: false    	
      
      t.timestamps
    end
  end
end
