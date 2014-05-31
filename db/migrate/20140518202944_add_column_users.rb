#encoding: utf-8

class AddColumnUsers < ActiveRecord::Migration
  def change
  	add_column :users, :activation_token, :string
  end
end
