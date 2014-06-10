#encoding: utf-8

class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :main_question, null: false
      t.text :description
      t.integer :author_id
      t.integer :upvotes, default: 0
      t.integer :downvotes, default: 0
      t.integer :numViews, default: 0

      t.timestamps
    end

    add_index :questions, :author_id
  end
end
