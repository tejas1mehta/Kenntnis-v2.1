#encoding: utf-8

class CreateUsers < ActiveRecord::Migration
  def change
		create_table :users do |t|
			t.string :session_token, null: false
	    t.string :email, null: false
	    t.string :password_digest, null: false
			t.string :name, null: false			
			t.text :about
			t.string :location
			t.text :education
			t.text :employment
			t.integer :credits, default: 500
      t.integer :num_credits_ans, default: 0
      t.boolean :activated, default: false

		  t.timestamps
		end

		add_index :users, :email, :unique => true
    add_index :users, :session_token
  end
end
