class AddStateToCalls < ActiveRecord::Migration
  def change
    add_column :calls, :state, :string, :default => ""
  end
end