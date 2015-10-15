class RemoveVotesStringFromImages < ActiveRecord::Migration
  def self.up
    remove_column :images, :votes
  end

  def self.down
    add_column :images, :votes, :string
  end
end
