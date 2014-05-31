#encoding: utf-8

class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :comment_body, null: false
      t.integer :author_id
      t.integer :upvotes
      t.integer :downvotes
      t.integer :parent_comment_id
      t.references :commentable, polymorphic: true

      t.timestamps
    end
  end
end
