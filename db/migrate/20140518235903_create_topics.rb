#encoding: utf-8


class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.string :title, null: false
      t.integer :author_id
      t.text :description
      t.integer :numViews, default: 0

      t.timestamps
    end

  end
end
