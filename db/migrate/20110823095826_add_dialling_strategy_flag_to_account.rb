class AddDiallingStrategyFlagToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :parallel_dial, :boolean, :default => true, :null => false
  end
end