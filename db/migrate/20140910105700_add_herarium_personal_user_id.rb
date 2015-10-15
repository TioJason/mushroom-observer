# encoding: utf-8

class AddHerariumPersonalUserId < ActiveRecord::Migration
  def self.up
    add_column(:herbaria, :personal_user_id, :integer, default: nil, null: true)
  end

  def self.down
    remove_column(:herbaria, :personal_user_id)
  end
end
