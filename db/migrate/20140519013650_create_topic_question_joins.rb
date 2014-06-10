#encoding: utf-8

class CreateTopicQuestionJoins < ActiveRecord::Migration
  def change
    create_table :topic_question_joins do |t|
      t.integer :topic_id, null: false
      t.integer :question_id, null: false

      t.timestamps
    end

    add_index :topic_question_joins, :topic_id
    add_index :topic_question_joins, :question_id
  end
end
