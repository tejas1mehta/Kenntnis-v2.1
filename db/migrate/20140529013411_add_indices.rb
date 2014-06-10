class AddIndices < ActiveRecord::Migration
  def change
    add_index :questions, :created_at
    add_index :answers, :created_at
    add_index :topics, :created_at
    add_index :users, :created_at
    add_index :followings, :created_at
    add_index :upvotes, :created_at
  end
end
