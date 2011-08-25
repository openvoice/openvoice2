class AddIncomingFlagToCalls < ActiveRecord::Migration
  def change
    add_column :calls, :incoming, :boolean, :default => false
  end
end
