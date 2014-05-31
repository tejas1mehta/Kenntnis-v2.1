class CreateUserQuestionA2as < ActiveRecord::Migration
  def change
    create_table :user_question_a2as do |t|
      t.integer :relevant_user_id, null: false
      t.integer :question_id, null: false

      t.timestamps
    end
    add_index :user_question_a2as, :question_id
  end
end
