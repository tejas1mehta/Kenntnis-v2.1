#encoding: utf-8

class CreateFollowings < ActiveRecord::Migration
  def change
    create_table :followings do |t|
      t.integer :f_id, null: false
      t.references :followable, polymorphic: true

      t.timestamps
    end

    add_index :followings, [:followable_id, :followable_type, :f_id], unique: true
  end
end
