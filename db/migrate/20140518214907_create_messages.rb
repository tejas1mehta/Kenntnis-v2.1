#encoding: utf-8

class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
    	t.text :message_body
    	t.string :subject
    	t.integer :sent_by_id, null: false
    	t.integer :sent_to_id, null: false
    	t.integer :parent_message_id
    	t.boolean :viewed, default: false 

      t.timestamps
    end

    add_index :messages, :sent_to_id
    add_index :messages, :sent_by_id
  end
end
