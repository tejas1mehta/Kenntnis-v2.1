#encoding: utf-8

class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.text :main_answer, null: false
      t.integer :question_id, null: false
      t.integer :author_id
      t.integer :upvotes, default: 0
      t.integer :downvotes, default: 0
      t.integer :numViews, default: 0

      t.timestamps
    end

    add_index :answers, :question_id
    add_index :answers, :author_id
  end
end
