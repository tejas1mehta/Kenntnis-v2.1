#encoding: utf-8

class CreateUpvotes < ActiveRecord::Migration
  def change
    create_table :upvotes do |t|
      t.integer :user_id, null: false
      t.references :upvoteable, polymorphic: true

      t.timestamps
    end

    add_index :upvotes, [:user_id, :upvoteable_id, :upvoteable_type], unique: true
  end
end
