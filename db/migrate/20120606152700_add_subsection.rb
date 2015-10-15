# encoding: utf-8

class AddSubsection < ActiveRecord::Migration
  def self.up
    change_column(:names, :rank, :enum, limit: Name.all_ranks)
  end

  def self.down
  end
end
